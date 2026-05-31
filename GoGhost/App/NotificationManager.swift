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

            let morning = UNMutableNotificationContent()
            morning.title = "Morning Check-In"
            morning.body = "Set your intentions. Lock in for the day."
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

            let night = UNMutableNotificationContent()
            night.title = "Night Reflection"
            night.body = "How did the day go? Time to reflect."
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
