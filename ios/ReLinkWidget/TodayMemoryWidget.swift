import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct TodayMemoryEntry: TimelineEntry {
    let date: Date
    let exists: Bool
    let title: String?
    let nodeName: String?
    let yearsAgo: Int?
    let memoryType: String?
    let totalCount: Int
}

// MARK: - Timeline Provider

struct TodayMemoryProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayMemoryEntry {
        TodayMemoryEntry(
            date: Date(),
            exists: true,
            title: "여름 휴가 사진",
            nodeName: "엄마",
            yearsAgo: 3,
            memoryType: "photo",
            totalCount: 5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayMemoryEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayMemoryEntry>) -> Void) {
        let entry = loadEntry()

        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func loadEntry() -> TodayMemoryEntry {
        let defaults = ReLinkUserDefaults.shared

        let exists = defaults?.bool(forKey: "today_memory_exists") ?? false
        let title = defaults?.string(forKey: "today_memory_title")
        let nodeName = defaults?.string(forKey: "today_memory_node")
        let yearsAgo = defaults?.object(forKey: "today_memory_years") as? Int
        let memoryType = defaults?.string(forKey: "today_memory_type")
        let totalCount = defaults?.integer(forKey: "today_memory_count") ?? 0

        return TodayMemoryEntry(
            date: Date(),
            exists: exists,
            title: title,
            nodeName: nodeName,
            yearsAgo: yearsAgo,
            memoryType: memoryType,
            totalCount: totalCount
        )
    }
}

// MARK: - Widget Views

struct TodayMemoryWidgetEntryView: View {
    var entry: TodayMemoryEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    // MARK: Helper — Memory type icon

    private var typeIcon: String {
        switch entry.memoryType {
        case "photo":
            return "photo.fill"
        case "voice":
            return "mic.fill"
        case "memo":
            return "note.text"
        default:
            return "heart.fill"
        }
    }

    private var typeLabel: String {
        switch entry.memoryType {
        case "photo":
            return "사진"
        case "voice":
            return "음성"
        case "memo":
            return "메모"
        default:
            return "기억"
        }
    }

    // MARK: Small — "N년 전 오늘" + node name

    private var smallView: some View {
        ZStack {
            ReLinkColors.backgroundDark

            if entry.exists, let years = entry.yearsAgo, let node = entry.nodeName {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ReLinkColors.primaryBlue)
                        Text("오늘의 기억")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ReLinkColors.textSecondary)
                        Spacer()
                    }

                    Spacer()

                    Text("\(years)년 전 오늘")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(ReLinkColors.primaryBlue)

                    HStack(spacing: 4) {
                        Image(systemName: typeIcon)
                            .font(.system(size: 10))
                            .foregroundColor(ReLinkColors.primaryMint)
                        Text(node)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ReLinkColors.textPrimary)
                            .lineLimit(1)
                    }

                    if entry.totalCount > 1 {
                        Text("외 \(entry.totalCount - 1)개의 기억")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(ReLinkColors.textTertiary)
                    }
                }
                .padding(16)
            } else {
                emptyStateSmall
            }
        }
        .widgetURL(URL(string: "relink://memory"))
    }

    // MARK: Medium — Title + node name + years ago + type icon

    private var mediumView: some View {
        ZStack {
            ReLinkColors.backgroundDark

            if entry.exists, let years = entry.yearsAgo, let node = entry.nodeName {
                HStack(spacing: 16) {
                    // Left: Years ago badge
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            ReLinkColors.primaryBlue.opacity(0.3),
                                            ReLinkColors.primaryMint.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)

                            VStack(spacing: 2) {
                                Text("\(years)")
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(ReLinkColors.primaryBlue)
                                Text("년 전")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(ReLinkColors.textSecondary)
                            }
                        }
                    }

                    // Right: Details
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ReLinkColors.primaryBlue)
                            Text("오늘의 기억")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ReLinkColors.textSecondary)
                            Spacer()
                        }

                        if let title = entry.title {
                            Text(title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(ReLinkColors.textPrimary)
                                .lineLimit(2)
                        }

                        HStack(spacing: 8) {
                            // Node name
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(ReLinkColors.primaryMint)
                                Text(node)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(ReLinkColors.textSecondary)
                            }

                            // Type
                            HStack(spacing: 4) {
                                Image(systemName: typeIcon)
                                    .font(.system(size: 10))
                                    .foregroundColor(ReLinkColors.primaryMint)
                                Text(typeLabel)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(ReLinkColors.textSecondary)
                            }
                        }

                        if entry.totalCount > 1 {
                            Text("오늘의 기억 \(entry.totalCount)개")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(ReLinkColors.textTertiary)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(16)
            } else {
                emptyStateMedium
            }
        }
        .widgetURL(URL(string: "relink://memory"))
    }

    // MARK: Empty States

    private var emptyStateSmall: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 28))
                .foregroundColor(ReLinkColors.textTertiary)
            Text("기억이\n없어요")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ReLinkColors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var emptyStateMedium: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 32))
                .foregroundColor(ReLinkColors.textTertiary)
            VStack(alignment: .leading, spacing: 4) {
                Text("오늘의 기억이 없어요")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ReLinkColors.textSecondary)
                Text("가족과의 기억을 저장해보세요")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(ReLinkColors.textTertiary)
            }
            Spacer()
        }
        .padding(16)
    }
}

// MARK: - Widget Configuration

struct TodayMemoryWidget: Widget {
    let kind: String = "TodayMemoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayMemoryProvider()) { entry in
            TodayMemoryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘의 기억")
        .description("N년 전 오늘, 가족과의 특별한 기억을 되돌아보세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
