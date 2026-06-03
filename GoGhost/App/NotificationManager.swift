import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let morningID = "gg-morning-checkin"
    private let nightID = "gg-night-checkin"

    func requestPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted { self.scheduleCheckInNotifications() }
                }
            case .authorized, .provisional:
                self.scheduleCheckInNotifications()
            default:
                break
            }
        }
    }

    func scheduleCheckInNotifications() {
        let center = UNUserNotificationCenter.current()
        let ud = UserDefaults.standard
        center.removePendingNotificationRequests(withIdentifiers: [morningID, nightID])

        let morningEnabled = ud.bool(forKey: AppStorageKeys.morningReminderEnabled)
        let nightEnabled = ud.bool(forKey: AppStorageKeys.nightReminderEnabled)

        if morningEnabled {
            let mh = ud.object(forKey: AppStorageKeys.morningReminderHourSet) != nil
                ? ud.integer(forKey: AppStorageKeys.morningReminderHour) : 7
            let mm = ud.integer(forKey: AppStorageKeys.morningReminderMinute)

            let morningBodies = [
                "The version of you that skips this is losing ground.",
                "Lock in before the day locks you out.",
                "Ghosts don't sleep in.",
                "Set the tone. Start the day right.",
                "Every day you skip, someone else gains ground."
            ]
            let morning = UNMutableNotificationContent()
            morning.title = "MORNING CHECK-IN"
            morning.body = morningBodies.randomElement() ?? "Set your intentions. Lock in."
            morning.sound = .default

            var morningTime = DateComponents()
            morningTime.hour = mh
            morningTime.minute = mm
            center.add(UNNotificationRequest(
                identifier: morningID,
                content: morning,
                trigger: UNCalendarNotificationTrigger(dateMatching: morningTime, repeats: true)
            ))
        }

        if nightEnabled {
            let nh = ud.object(forKey: AppStorageKeys.nightReminderHourSet) != nil
                ? ud.integer(forKey: AppStorageKeys.nightReminderHour) : 21
            let nm = ud.integer(forKey: AppStorageKeys.nightReminderMinute)

            let nightBodies = [
                "The streak doesn't count itself. Reflect.",
                "Cap the day. What did you do with it?",
                "Ghosts don't take days off.",
                "Don't let today slip by unaccounted for.",
                "Close the loop. Your future self is watching."
            ]
            let night = UNMutableNotificationContent()
            night.title = "NIGHT REFLECTION"
            night.body = nightBodies.randomElement() ?? "Cap the day. What did you do with it?"
            night.sound = .default

            var nightTime = DateComponents()
            nightTime.hour = nh
            nightTime.minute = nm
            center.add(UNNotificationRequest(
                identifier: nightID,
                content: night,
                trigger: UNCalendarNotificationTrigger(dateMatching: nightTime, repeats: true)
            ))
        }
    }

    func cancelCheckInNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [morningID, nightID])
    }
}
