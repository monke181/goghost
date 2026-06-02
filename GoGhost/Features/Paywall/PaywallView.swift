import SwiftUI
import RevenueCat

/// Hard paywall shown after onboarding. The gate (RootRouter) swaps to the main
/// app automatically the moment `SubscriptionManager.isSubscribed` flips true,
/// so this view doesn't need a success callback — it just drives purchase/restore.
struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptions
    @State private var selected: Package?

    // TODO: point these at the real hosted policies before submitting to review.
    // Apple rejects the build if these are dead links (Guideline 3.1.2).
    #warning("Replace placeholder Terms/Privacy URLs with real hosted pages before App Store submission")
    private let termsURL = URL(string: "https://goghost.app/terms")!
    private let privacyURL = URL(string: "https://goghost.app/privacy")!

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        header
                        benefits
                        plans
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 72)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)

                footer
            }
        }
        .task {
            if subscriptions.packages.isEmpty {
                await subscriptions.loadOfferings()
            }
            selected = selected ?? defaultPackage
        }
        .onChange(of: subscriptions.packages.count) { _, _ in
            selected = selected ?? defaultPackage
        }
    }

    // ── Header ───────────────────────────────────────────────────────────────

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GO GHOST")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Text("UNLOCK THE\nFULL SYSTEM.")
                .font(GGFonts.display)
                .foregroundStyle(GGColors.textPrimary)

            Rectangle().fill(GGColors.border).frame(height: 1)
        }
    }

    // ── Benefits ─────────────────────────────────────────────────────────────

    private let features = [
        "Unlimited Ghost Mode sessions.",
        "Block any app at the OS level.",
        "Daily check-ins and night reflections.",
        "Your full 90-day run, tracked.",
    ]

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 12) {
                    Rectangle()
                        .fill(GGColors.accent)
                        .frame(width: 3, height: 18)
                    Text(feature)
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textSecondary)
                        .lineSpacing(3)
                }
            }
        }
    }

    // ── Plans ────────────────────────────────────────────────────────────────

    @ViewBuilder
    private var plans: some View {
        if subscriptions.packages.isEmpty {
            if subscriptions.isLoading {
                HStack {
                    Spacer()
                    ProgressView().tint(GGColors.textSecondary)
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                // No offerings — almost always means the RevenueCat key/products
                // aren't configured yet. See SubscriptionManager setup TODO.
                Text("PLANS UNAVAILABLE. CHECK YOUR CONNECTION AND TRY AGAIN.")
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                    .padding(.vertical, 12)
            }
        } else {
            VStack(spacing: 12) {
                ForEach(subscriptions.packages, id: \.identifier) { package in
                    planRow(package)
                }
            }
        }
    }

    private func planRow(_ package: Package) -> some View {
        let isSelected = selected?.identifier == package.identifier
        return Button {
            selected = package
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.displayTitle)
                        .font(GGFonts.headline)
                        .foregroundStyle(isSelected ? GGColors.textPrimary : GGColors.textSecondary)
                        .tightTracking()
                    if let subtitle = package.displaySubtitle {
                        Text(subtitle)
                            .font(GGFonts.caption)
                            .foregroundStyle(GGColors.textTertiary)
                            .tightTracking()
                    }
                }
                Spacer()
                Text(package.storeProduct.localizedPriceString)
                    .font(GGFonts.headline)
                    .foregroundStyle(isSelected ? GGColors.accent : GGColors.textSecondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .overlay(
                Rectangle().stroke(
                    isSelected ? GGColors.accent : GGColors.border,
                    lineWidth: isSelected ? 2 : 1
                )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // ── Footer ───────────────────────────────────────────────────────────────

    private var footer: some View {
        VStack(spacing: 14) {
            if let message = subscriptions.lastErrorMessage {
                Text(message.uppercased())
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.danger)
                    .tightTracking()
                    .multilineTextAlignment(.center)
            }

            GGPrimaryButton(title: subscriptions.isLoading ? "…" : "START") {
                guard let package = selected else { return }
                Task { await subscriptions.purchase(package) }
            }
            .disabled(selected == nil || subscriptions.isLoading)
            .opacity(selected == nil ? 0.4 : 1)

            // Required auto-renew disclosure (App Store Guideline 3.1.2). Must be
            // visible on the purchase screen near the buy button.
            Text(disclosureText)
                .font(GGFonts.caption)
                .foregroundStyle(GGColors.textTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 20) {
                Button("RESTORE") {
                    Task { await subscriptions.restore() }
                }
                Link("TERMS", destination: termsURL)
                Link("PRIVACY", destination: privacyURL)
            }
            .font(GGFonts.caption)
            .foregroundStyle(GGColors.textTertiary)
            .tightTracking()
            .buttonStyle(.plain)
            .disabled(subscriptions.isLoading)
        }
        .padding(.horizontal, 32)
        .padding(.top, 16)
        .padding(.bottom, 40)
        .background(GGColors.background)
        .overlay(alignment: .top) {
            Rectangle().fill(GGColors.border).frame(height: 1)
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    /// Auto-renew terms Apple requires on the purchase screen. Adapts when the
    /// selected plan offers a free trial so the trial-to-paid conversion is disclosed.
    private var disclosureText: String {
        let base = "Auto-renews at the selected price until cancelled. Cancel anytime in App Store settings."
        guard let pkg = selected,
              let intro = pkg.storeProduct.introductoryDiscount,
              intro.price == 0 else { return base }
        return "After the free trial, your subscription auto-renews at the selected price until cancelled. Cancel anytime in App Store settings."
    }

    /// Default to the annual plan if present (best value), else the first.
    private var defaultPackage: Package? {
        subscriptions.packages.first { $0.packageType == .annual }
            ?? subscriptions.packages.first
    }
}

private extension Package {
    /// Human label for the plan row, derived from the RevenueCat package type
    /// so it stays correct regardless of how products are named in App Store Connect.
    var displayTitle: String {
        switch packageType {
        case .annual:    return "YEARLY"
        case .monthly:   return "MONTHLY"
        case .weekly:    return "WEEKLY"
        case .lifetime:  return "LIFETIME"
        case .sixMonth:  return "6 MONTHS"
        case .threeMonth: return "3 MONTHS"
        case .twoMonth:  return "2 MONTHS"
        default:         return storeProduct.localizedTitle.uppercased()
        }
    }

    /// Secondary line, e.g. trial info if the product offers an intro period.
    var displaySubtitle: String? {
        if let intro = storeProduct.introductoryDiscount, intro.price == 0 {
            let unit = intro.subscriptionPeriod.unit.singular
            let count = intro.subscriptionPeriod.value
            return "\(count)-\(unit) free trial".uppercased()
        }
        return nil
    }
}

private extension SubscriptionPeriod.Unit {
    var singular: String {
        switch self {
        case .day:   return "day"
        case .week:  return "week"
        case .month: return "month"
        case .year:  return "year"
        @unknown default: return "period"
        }
    }
}
