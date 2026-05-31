import SwiftUI
import UserNotifications

@Observable
final class SettingsViewModel {
    var morningEnabled: Bool
    var nightEnabled: Bool
    var morningHour: Int
    var morningMinute: Int
    var nightHour: Int
    var nightMinute: Int
    var defaultDuration: Int
    var hapticsEnabled: Bool

    var showMorningPicker = false
    var showNightPicker = false
    var showResetConfirm = false
    var showAppPicker = false

    init() {
        let ud = UserDefaults.standard
        morningEnabled = ud.bool(forKey: AppStorageKeys.morningReminderEnabled)
        nightEnabled = ud.bool(forKey: AppStorageKeys.nightReminderEnabled)

        morningHour = ud.object(forKey: AppStorageKeys.morningReminderHourSet) != nil
            ? ud.integer(forKey: AppStorageKeys.morningReminderHour) : 7
        morningMinute = ud.integer(forKey: AppStorageKeys.morningReminderMinute)

        nightHour = ud.object(forKey: AppStorageKeys.nightReminderHourSet) != nil
            ? ud.integer(forKey: AppStorageKeys.nightReminderHour) : 21
        nightMinute = ud.integer(forKey: AppStorageKeys.nightReminderMinute)

        let dur = ud.integer(forKey: AppStorageKeys.defaultGhostDuration)
        defaultDuration = dur == 0 ? 25 : dur

        let haptics = ud.object(forKey: AppStorageKeys.hapticsEnabled)
        hapticsEnabled = haptics == nil ? true : ud.bool(forKey: AppStorageKeys.hapticsEnabled)
    }

    func toggleMorning() {
        morningEnabled.toggle()
        UserDefaults.standard.set(morningEnabled, forKey: AppStorageKeys.morningReminderEnabled)
        syncNotifications()
    }

    func toggleNight() {
        nightEnabled.toggle()
        UserDefaults.standard.set(nightEnabled, forKey: AppStorageKeys.nightReminderEnabled)
        syncNotifications()
    }

    func applyMorningTime(_ date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        morningHour = comps.hour ?? 7
        morningMinute = comps.minute ?? 30
        let ud = UserDefaults.standard
        ud.set(morningHour, forKey: AppStorageKeys.morningReminderHour)
        ud.set(morningMinute, forKey: AppStorageKeys.morningReminderMinute)
        ud.set(true, forKey: AppStorageKeys.morningReminderHourSet)
        syncNotifications()
    }

    func applyNightTime(_ date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        nightHour = comps.hour ?? 21
        nightMinute = comps.minute ?? 0
        let ud = UserDefaults.standard
        ud.set(nightHour, forKey: AppStorageKeys.nightReminderHour)
        ud.set(nightMinute, forKey: AppStorageKeys.nightReminderMinute)
        ud.set(true, forKey: AppStorageKeys.nightReminderHourSet)
        syncNotifications()
    }

    func setDefaultDuration(_ minutes: Int) {
        defaultDuration = minutes
        UserDefaults.standard.set(minutes, forKey: AppStorageKeys.defaultGhostDuration)
    }

    func toggleHaptics() {
        hapticsEnabled.toggle()
        UserDefaults.standard.set(hapticsEnabled, forKey: AppStorageKeys.hapticsEnabled)
    }

    var morningTimeDate: Date {
        Calendar.current.date(from: DateComponents(hour: morningHour, minute: morningMinute)) ?? Date()
    }

    var nightTimeDate: Date {
        Calendar.current.date(from: DateComponents(hour: nightHour, minute: nightMinute)) ?? Date()
    }

    var morningTimeString: String { formatTime(hour: morningHour, minute: morningMinute) }
    var nightTimeString: String { formatTime(hour: nightHour, minute: nightMinute) }

    private func formatTime(hour: Int, minute: Int) -> String {
        let comps = DateComponents(hour: hour, minute: minute)
        guard let date = Calendar.current.date(from: comps) else { return "--:--" }
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f.string(from: date).uppercased()
    }

    private func syncNotifications() {
        if morningEnabled || nightEnabled {
            NotificationManager.shared.scheduleCheckInNotifications()
        } else {
            NotificationManager.shared.cancelCheckInNotifications()
        }
    }
}
