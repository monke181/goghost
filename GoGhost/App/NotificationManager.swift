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
        center.removePendingNotificationRequests(withIdentifiers: [morningID, nightID])

        let morning = UNMutableNotificationContent()
        morning.title = "Morning Check-In"
        morning.body = "Set your intentions. Lock in for the day."
        morning.sound = .default

        var morningTime = DateComponents()
        morningTime.hour = 7
        morningTime.minute = 30
        center.add(UNNotificationRequest(
            identifier: morningID,
            content: morning,
            trigger: UNCalendarNotificationTrigger(dateMatching: morningTime, repeats: true)
        ))

        let night = UNMutableNotificationContent()
        night.title = "Night Reflection"
        night.body = "How did the day go? Time to reflect."
        night.sound = .default

        var nightTime = DateComponents()
        nightTime.hour = 21
        nightTime.minute = 0
        center.add(UNNotificationRequest(
            identifier: nightID,
            content: night,
            trigger: UNCalendarNotificationTrigger(dateMatching: nightTime, repeats: true)
        ))
    }

    func cancelCheckInNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [morningID, nightID])
    }
}
