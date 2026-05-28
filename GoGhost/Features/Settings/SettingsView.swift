import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()
            VStack {
                Text("SETTINGS")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textSecondary)
                    .tightTracking()
            }
        }
        .navigationBarHidden(true)
    }
}
