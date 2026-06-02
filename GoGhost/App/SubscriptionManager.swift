import Foundation
import RevenueCat

/// Wraps RevenueCat. Owns the single source of truth for whether the user has
/// access to the app (`isSubscribed`) and exposes the current offering's
/// packages for the paywall to render.
///
/// ──────────────────────────────────────────────────────────────────────────
/// SETUP TODO (before shipping):
///   1. Create a project in the RevenueCat dashboard, add this app, and paste
///      the public **Apple App Store** SDK key into `Self.apiKey` below.
///   2. In App Store Connect, create the subscription products and add their
///      IDs to a RevenueCat Offering (default offering = "current").
///   3. Create an Entitlement in RevenueCat named exactly `entitlementID`
///      ("pro") and attach the products to it.
/// Until step 1 is done the SDK runs against a placeholder key: offerings come
/// back empty and `isSubscribed` stays false, so the paywall shows but no real
/// purchase can complete.
/// ──────────────────────────────────────────────────────────────────────────
@Observable
@MainActor
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    // TODO: replace with the real RevenueCat public Apple SDK key (starts with "appl_").
    private static let apiKey = "appl_TEpoDudmNVwyHMwRxmifvVRmZdz"

    /// Entitlement identifier configured in the RevenueCat dashboard.
    private static let entitlementID = "pro"

    /// True when the user holds the "pro" entitlement. Drives the paywall gate.
    private(set) var isSubscribed = false

    /// The packages of the current offering, ready for the paywall to list.
    private(set) var packages: [Package] = []

    /// True while offerings are loading or a purchase/restore is in flight.
    private(set) var isLoading = false

    /// Set when an offering fetch or purchase fails, for surfacing in the UI.
    private(set) var lastErrorMessage: String?

    /// Until `configure()` runs we don't know the real status; the gate treats
    /// this as "still deciding" and shows a loading state rather than a flash
    /// of either the paywall or the app.
    private(set) var hasResolvedInitialStatus = false

    private init() {}

    /// Call once at app launch.
    func configure() {
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: Self.apiKey)
        observeCustomerInfo()
    }

    /// Listens for entitlement changes for the lifetime of the app (purchases,
    /// restores, renewals, expirations) and keeps `isSubscribed` in sync.
    private func observeCustomerInfo() {
        Task {
            for await info in Purchases.shared.customerInfoStream {
                apply(info)
                hasResolvedInitialStatus = true
            }
        }
    }

    private func apply(_ info: CustomerInfo) {
        isSubscribed = info.entitlements[Self.entitlementID]?.isActive == true
    }

    /// Loads the current offering's packages for the paywall.
    func loadOfferings() async {
        isLoading = true
        lastErrorMessage = nil
        defer { isLoading = false }
        do {
            let offerings = try await Purchases.shared.offerings()
            packages = offerings.current?.availablePackages ?? []
        } catch {
            lastErrorMessage = error.localizedDescription
            packages = []
        }
    }

    /// Purchases a package. Returns true if the user ends up subscribed.
    /// A user-cancelled purchase returns false without setting an error.
    @discardableResult
    func purchase(_ package: Package) async -> Bool {
        isLoading = true
        lastErrorMessage = nil
        defer { isLoading = false }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return false }
            apply(result.customerInfo)
            return isSubscribed
        } catch {
            lastErrorMessage = error.localizedDescription
            return false
        }
    }

    /// Restores prior purchases. Returns true if an active entitlement is found.
    @discardableResult
    func restore() async -> Bool {
        isLoading = true
        lastErrorMessage = nil
        defer { isLoading = false }
        do {
            let info = try await Purchases.shared.restorePurchases()
            apply(info)
            return isSubscribed
        } catch {
            lastErrorMessage = error.localizedDescription
            return false
        }
    }
}
