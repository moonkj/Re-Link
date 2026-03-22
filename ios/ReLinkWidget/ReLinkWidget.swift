import WidgetKit
import SwiftUI

@main
struct ReLinkWidgetBundle: WidgetBundle {
    var body: some Widget {
        AnniversaryWidget()
        TodayMemoryWidget()
        FamilyStatsWidget()
    }
}

// MARK: - Shared Helpers

struct ReLinkColors {
    static let primaryMint = Color(red: 0x8B / 255.0, green: 0x5C / 255.0, blue: 0xF6 / 255.0)
    static let primaryBlue = Color(red: 0x06 / 255.0, green: 0xB6 / 255.0, blue: 0xD4 / 255.0)
    static let backgroundDark = Color(red: 0x0D / 255.0, green: 0x11 / 255.0, blue: 0x17 / 255.0)
    static let surfaceDark = Color(red: 0x16 / 255.0, green: 0x1B / 255.0, blue: 0x22 / 255.0)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.45)
    static let accent = Color(red: 0xFF / 255.0, green: 0x6B / 255.0, blue: 0x6B / 255.0)
}

struct ReLinkUserDefaults {
    static let suiteName = "group.com.relink.reLink"

    static var shared: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
}
