import SwiftUI
import SwiftData
import FamilyControls

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ScreenTimeManager.self) private var screenTime
    @Environment(SubscriptionManager.self) private var subscriptions
    @State private var vm = SettingsViewModel()
    @State private var pickerSelection = FamilyActivitySelection()

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ──────────────────────────────────────────
                    Text("SETTINGS")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                        .padding(.horizontal, 24)
                        .padding(.top, 64)
                        .padding(.bottom, 32)

                    // ── Subscription ────────────────────────────────────
                    sectionHeader("SUBSCRIPTION")
                    subscriptionSection
                    divider()

                    // ── Ghost Mode ──────────────────────────────────────
                    sectionHeader("GHOST MODE")

                    VStack(alignment: .leading, spacing: 10) {
                        Text("DEFAULT SESSION")
                            .font(GGFonts.label)
                            .foregroundStyle(GGColors.textSecondary)
                            .tightTracking()

                        HStack(spacing: 0) {
                            ForEach([25, 50, 90], id: \.self) { mins in
                                Button { vm.setDefaultDuration(mins) } label: {
                                    Text("\(mins)M")
                                        .font(GGFonts.label)
                                        .tightTracking()
                                        .foregroundStyle(
                                            vm.defaultDuration == mins
                                                ? GGColors.background : GGColors.textSecondary
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(vm.defaultDuration == mins ? GGColors.textPrimary : .clear)
                                        .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)

                    divider()
                    appBlockingSection

                    // ── Notifications ───────────────────────────────────
                    divider()
                    sectionHeader("NOTIFICATIONS")

                    notificationRow(
                        label: "MORNING CHECK-IN",
                        timeString: vm.morningTimeString,
                        isOn: vm.morningEnabled,
                        onToggle: { vm.toggleMorning() },
                        onTimeTap: { vm.showMorningPicker = true }
                    )

                    Rectangle().fill(GGColors.border).frame(height: 1).padding(.leading, 24)

                    notificationRow(
                        label: "NIGHT REFLECTION",
                        timeString: vm.nightTimeString,
                        isOn: vm.nightEnabled,
                        onToggle: { vm.toggleNight() },
                        onTimeTap: { vm.showNightPicker = true }
                    )

                    // ── Preferences ─────────────────────────────────────
                    divider()
                    sectionHeader("PREFERENCES")

                    toggleRow(
                        label: "HAPTIC FEEDBACK",
                        detail: "Vibration on session start and end.",
                        isOn: vm.hapticsEnabled,
                        onToggle: { vm.toggleHaptics() }
                    )

                    // ── Data ─────────────────────────────────────────────
                    divider()
                    sectionHeader("DATA")

                    Button { vm.showResetConfirm = true } label: {
                        HStack {
                            Text("RESET ALL DATA")
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.danger)
                                .tightTracking()
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .onAppear { screenTime.refreshAuthStatus() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { screenTime.refreshAuthStatus() }
        }
        // ── App picker ───────────────────────────────────────────────────
        .sheet(isPresented: $vm.showAppPicker, onDismiss: {
            screenTime.saveSelection(pickerSelection)
        }) {
            NavigationStack {
                FamilyActivityPicker(selection: $pickerSelection)
                    .navigationTitle("Block During Ghost Mode")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { vm.showAppPicker = false }
                                .font(GGFonts.label)
                                .tightTracking()
                        }
                    }
            }
        }
        // ── Time pickers ─────────────────────────────────────────────────
        .sheet(isPresented: $vm.showMorningPicker) {
            TimePickerSheet(
                title: "MORNING CHECK-IN",
                selection: vm.morningTimeDate,
                onDone: { date in vm.applyMorningTime(date); vm.showMorningPicker = false },
                onDismiss: { vm.showMorningPicker = false }
            )
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $vm.showNightPicker) {
            TimePickerSheet(
                title: "NIGHT REFLECTION",
                selection: vm.nightTimeDate,
                onDone: { date in vm.applyNightTime(date); vm.showNightPicker = false },
                onDismiss: { vm.showNightPicker = false }
            )
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.hidden)
        }
        // ── Reset dialog ─────────────────────────────────────────────────
        .confirmationDialog("RESET ALL DATA", isPresented: $vm.showResetConfirm, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { resetAllData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all runs, sessions, and check-ins. This cannot be undone.")
        }
    }

    // ── Subscription Section ─────────────────────────────────────────────

    @ViewBuilder
    private var subscriptionSection: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(subscriptions.isSubscribed ? "GOGHOST PRO" : "FREE")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textPrimary)
                    .tightTracking()
                Text(subscriptions.isSubscribed ? "ACTIVE" : "NOT SUBSCRIBED")
                    .font(GGFonts.caption)
                    .foregroundStyle(subscriptions.isSubscribed ? GGColors.accent : GGColors.textTertiary)
                    .tightTracking()
            }

            Spacer()

            if subscriptions.isSubscribed {
                // Deep-link to the system subscription management screen.
                Button {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    subscriptionPill("MANAGE")
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    Task { await subscriptions.restore() }
                } label: {
                    subscriptionPill("RESTORE")
                }
                .buttonStyle(.plain)
                .disabled(subscriptions.isLoading)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private func subscriptionPill(_ text: String) -> some View {
        Text(text)
            .font(GGFonts.label)
            .tightTracking()
            .foregroundStyle(GGColors.textSecondary)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
    }

    // ── App Blocking Section ─────────────────────────────────────────────

    @ViewBuilder
    private var appBlockingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("BLOCK DURING GHOST MODE")

            if screenTime.authorizationStatus == .denied {
                // ── Denied ────────────────────────────────────────────
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PERMISSION DENIED")
                            .font(GGFonts.label)
                            .foregroundStyle(GGColors.textSecondary)
                            .tightTracking()
                        Text("Re-enable in iOS Settings › Screen Time.")
                            .font(GGFonts.caption)
                            .foregroundStyle(GGColors.textTertiary)
                    }
                    Spacer()
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("OPEN")
                            .font(GGFonts.label)
                            .tightTracking()
                            .foregroundStyle(GGColors.textSecondary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            } else {
                // ── Authorized or not yet asked — same row either way ─
                Button {
                    if screenTime.authorizationStatus == .approved {
                        pickerSelection = screenTime.activitySelection
                        vm.showAppPicker = true
                    } else {
                        Task {
                            await screenTime.requestAuthorization()
                            if screenTime.authorizationStatus == .approved {
                                pickerSelection = screenTime.activitySelection
                                vm.showAppPicker = true
                            }
                        }
                    }
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CHOOSE APPS TO BLOCK")
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.textPrimary)
                                .tightTracking()
                            Text(
                                screenTime.authorizationStatus != .approved
                                    ? "REQUIRES SCREEN TIME PERMISSION"
                                    : screenTime.isSelectionEmpty
                                        ? "NONE SELECTED"
                                        : screenTime.selectionSummary + " BLOCKED"
                            )
                            .font(GGFonts.caption)
                            .foregroundStyle(
                                screenTime.authorizationStatus == .approved && !screenTime.isSelectionEmpty
                                    ? GGColors.accent : GGColors.textTertiary
                            )
                            .tightTracking()
                        }
                        Spacer()
                        Text("›")
                            .font(GGFonts.headline)
                            .foregroundStyle(GGColors.textSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Text("SELECTED APPS ARE BLOCKED AT THE OS LEVEL DURING EVERY GHOST MODE SESSION.")
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
        }
    }

    // ── Reusable rows ────────────────────────────────────────────────────

    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(GGFonts.label)
            .foregroundStyle(GGColors.textTertiary)
            .tightTracking()
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 4)
    }

    @ViewBuilder
    private func divider() -> some View {
        Rectangle().fill(GGColors.border).frame(height: 1).padding(.horizontal, 24)
    }

    @ViewBuilder
    private func notificationRow(
        label: String,
        timeString: String,
        isOn: Bool,
        onToggle: @escaping () -> Void,
        onTimeTap: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(GGFonts.label)
                    .foregroundStyle(isOn ? GGColors.textPrimary : GGColors.textSecondary)
                    .tightTracking()

                Button(action: onTimeTap) {
                    HStack(spacing: 4) {
                        Text(timeString)
                            .font(GGFonts.bodyMed)
                            .foregroundStyle(isOn ? GGColors.accent : GGColors.textTertiary)
                        Text("›")
                            .font(GGFonts.body)
                            .foregroundStyle(isOn ? GGColors.accent : GGColors.textTertiary)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!isOn)
            }

            Spacer()

            Button(action: onToggle) {
                Text(isOn ? "ON" : "OFF")
                    .font(GGFonts.label)
                    .foregroundStyle(isOn ? GGColors.background : GGColors.textSecondary)
                    .tightTracking()
                    .frame(minWidth: 36)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(isOn ? GGColors.accent : .clear)
                    .overlay(Rectangle().stroke(isOn ? GGColors.accent : GGColors.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private func toggleRow(
        label: String,
        detail: String,
        isOn: Bool,
        onToggle: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textPrimary)
                    .tightTracking()
                Text(detail.uppercased())
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
            }

            Spacer()

            Button(action: onToggle) {
                Text(isOn ? "ON" : "OFF")
                    .font(GGFonts.label)
                    .foregroundStyle(isOn ? GGColors.background : GGColors.textSecondary)
                    .tightTracking()
                    .frame(minWidth: 36)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(isOn ? GGColors.accent : .clear)
                    .overlay(Rectangle().stroke(isOn ? GGColors.accent : GGColors.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    // ── Data reset ───────────────────────────────────────────────────────

    private func resetAllData() {
        do {
            try context.delete(model: Run.self)
            try context.save()
        } catch {
            // best-effort
        }
    }
}

// ── Time Picker Sheet ─────────────────────────────────────────────────────

private struct TimePickerSheet: View {
    let title: String
    let selection: Date
    let onDone: (Date) -> Void
    let onDismiss: () -> Void

    @State private var current: Date

    init(title: String, selection: Date, onDone: @escaping (Date) -> Void, onDismiss: @escaping () -> Void) {
        self.title = title
        self.selection = selection
        self.onDone = onDone
        self.onDismiss = onDismiss
        _current = State(initialValue: selection)
    }

    var body: some View {
        ZStack {
            GGColors.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onDismiss) {
                        Text("CANCEL")
                            .font(GGFonts.label)
                            .foregroundStyle(GGColors.textSecondary)
                            .tightTracking()
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(title)
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()

                    Spacer()

                    Button { onDone(current) } label: {
                        Text("SET")
                            .font(GGFonts.label)
                            .foregroundStyle(GGColors.accent)
                            .tightTracking()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                Rectangle().fill(GGColors.border).frame(height: 1)

                DatePicker("", selection: $current, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
            }
        }
    }
}
