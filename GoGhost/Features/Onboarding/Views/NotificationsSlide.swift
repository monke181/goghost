import SwiftUI
import UserNotifications

struct NotificationsSlide: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("STAY ON\nSCHEDULE.")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(2)

                VStack(alignment: .leading, spacing: 14) {
                    reminder("7:30 AM — morning check-in.")
                    reminder("9:00 PM — night reflection.")
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 16) {
                GGPrimaryButton(title: "ENABLE NOTIFICATIONS") {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        if granted {
                            NotificationManager.shared.scheduleCheckInNotifications()
                        }
                        DispatchQueue.main.async { onContinue() }
                    }
                }

                Button(action: onContinue) {
                    Text("SKIP")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 56)
        }
    }

    private func reminder(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(GGColors.accent)
                .frame(width: 3, height: 18)
            Text(text)
                .font(GGFonts.body)
                .foregroundStyle(GGColors.textSecondary)
                .lineSpacing(3)
        }
    }
}
