import WidgetKit
import SwiftUI

// MARK: - Data Model

struct AnniversaryItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let daysUntil: Int
    let turningAge: Int?
    let date: String
    let isToday: Bool

    enum CodingKeys: String, CodingKey {
        case name, daysUntil, turningAge, date, isToday
    }

    var dDayText: String {
        if isToday {
            return "D-DAY"
        } else {
            return "D-\(daysUntil)"
        }
    }

    var ageText: String? {
        guard let age = turningAge else { return nil }
        return "\(age)세"
    }
}

// MARK: - Timeline Entry

struct AnniversaryEntry: TimelineEntry {
    let date: Date
    let anniversaries: [AnniversaryItem]
    let totalCount: Int
    let nextName: String?
    let nextDays: Int?
}

// MARK: - Timeline Provider

struct AnniversaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> AnniversaryEntry {
        AnniversaryEntry(
            date: Date(),
            anniversaries: [
                AnniversaryItem(name: "엄마", daysUntil: 3, turningAge: 55, date: "3월 25일", isToday: false),
                AnniversaryItem(name: "아빠", daysUntil: 12, turningAge: 58, date: "4월 3일", isToday: false),
                AnniversaryItem(name: "동생", daysUntil: 30, turningAge: 25, date: "4월 21일", isToday: false),
            ],
            totalCount: 3,
            nextName: "엄마",
            nextDays: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AnniversaryEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AnniversaryEntry>) -> Void) {
        let entry = loadEntry()

        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func loadEntry() -> AnniversaryEntry {
        let defaults = ReLinkUserDefaults.shared

        var anniversaries: [AnniversaryItem] = []
        if let jsonString = defaults?.string(forKey: "anniversary_list"),
           let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([AnniversaryItem].self, from: data) {
                anniversaries = decoded
            }
        }

        let totalCount = defaults?.integer(forKey: "anniversary_count") ?? 0
        let nextName = defaults?.string(forKey: "anniversary_next_name")
        let nextDays = defaults?.object(forKey: "anniversary_next_days") as? Int

        return AnniversaryEntry(
            date: Date(),
            anniversaries: anniversaries,
            totalCount: totalCount,
            nextName: nextName,
            nextDays: nextDays
        )
    }
}

// MARK: - Widget Views

struct AnniversaryWidgetEntryView: View {
    var entry: AnniversaryEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            smallView
        }
    }

    // MARK: Small — Next anniversary + D-day

    private var smallView: some View {
        ZStack {
            ReLinkColors.backgroundDark

            if let first = entry.anniversaries.first {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ReLinkColors.primaryMint)
                        Text("기념일")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ReLinkColors.textSecondary)
                        Spacer()
                    }

                    Spacer()

                    Text(first.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ReLinkColors.textPrimary)
                        .lineLimit(1)

                    Text(first.dDayText)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(first.isToday ? ReLinkColors.accent : ReLinkColors.primaryBlue)

                    if let ageText = first.ageText {
                        Text(ageText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ReLinkColors.textTertiary)
                    }
                }
                .padding(16)
            } else {
                emptyStateSmall
            }
        }
        .widgetURL(URL(string: "relink://birthday"))
    }

    // MARK: Medium — Top 3 anniversaries

    private var mediumView: some View {
        ZStack {
            ReLinkColors.backgroundDark

            if entry.anniversaries.isEmpty {
                emptyStateMedium
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ReLinkColors.primaryMint)
                        Text("다가오는 기념일")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ReLinkColors.textSecondary)
                        Spacer()
                        if entry.totalCount > 3 {
                            Text("+\(entry.totalCount - 3)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ReLinkColors.textTertiary)
                        }
                    }

                    Spacer(minLength: 4)

                    ForEach(Array(entry.anniversaries.prefix(3).enumerated()), id: \.offset) { index, item in
                        anniversaryRow(item: item)
                        if index < min(2, entry.anniversaries.count - 1) {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(16)
            }
        }
        .widgetURL(URL(string: "relink://birthday"))
    }

    // MARK: Large — Top 5 with details

    private var largeView: some View {
        ZStack {
            ReLinkColors.backgroundDark

            if entry.anniversaries.isEmpty {
                emptyStateLarge
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ReLinkColors.primaryMint)
                        Text("다가오는 기념일")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(ReLinkColors.textPrimary)
                        Spacer()
                        Text("\(entry.totalCount)명")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ReLinkColors.textTertiary)
                    }

                    Divider()
                        .background(Color.white.opacity(0.15))

                    ForEach(Array(entry.anniversaries.prefix(5).enumerated()), id: \.offset) { index, item in
                        anniversaryDetailRow(item: item)
                        if index < min(4, entry.anniversaries.count - 1) {
                            Divider()
                                .background(Color.white.opacity(0.08))
                        }
                    }

                    Spacer(minLength: 0)

                    if entry.totalCount > 5 {
                        HStack {
                            Spacer()
                            Text("더 보기 (\(entry.totalCount - 5)명)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ReLinkColors.primaryBlue)
                            Spacer()
                        }
                    }
                }
                .padding(16)
            }
        }
        .widgetURL(URL(string: "relink://birthday"))
    }

    // MARK: Row Components

    private func anniversaryRow(item: AnniversaryItem) -> some View {
        HStack {
            Circle()
                .fill(item.isToday ? ReLinkColors.accent : ReLinkColors.primaryMint.opacity(0.3))
                .frame(width: 8, height: 8)

            Text(item.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ReLinkColors.textPrimary)
                .lineLimit(1)

            if let ageText = item.ageText {
                Text(ageText)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(ReLinkColors.textTertiary)
            }

            Spacer()

            Text(item.dDayText)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(item.isToday ? ReLinkColors.accent : ReLinkColors.primaryBlue)
        }
    }

    private func anniversaryDetailRow(item: AnniversaryItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.isToday ? ReLinkColors.accent.opacity(0.2) : ReLinkColors.primaryMint.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(String(item.name.prefix(1)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(item.isToday ? ReLinkColors.accent : ReLinkColors.primaryMint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ReLinkColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(item.date)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(ReLinkColors.textTertiary)
                    if let ageText = item.ageText {
                        Text("(\(ageText))")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(ReLinkColors.textTertiary)
                    }
                }
            }

            Spacer()

            Text(item.dDayText)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(item.isToday ? ReLinkColors.accent : ReLinkColors.primaryBlue)
        }
        .padding(.vertical, 4)
    }

    // MARK: Empty States

    private var emptyStateSmall: some View {
        VStack(spacing: 8) {
            Image(systemName: "gift")
                .font(.system(size: 28))
                .foregroundColor(ReLinkColors.textTertiary)
            Text("기념일을\n추가해보세요")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ReLinkColors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var emptyStateMedium: some View {
        HStack {
            Image(systemName: "gift")
                .font(.system(size: 32))
                .foregroundColor(ReLinkColors.textTertiary)
            VStack(alignment: .leading, spacing: 4) {
                Text("다가오는 기념일이 없어요")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ReLinkColors.textSecondary)
                Text("가족의 생일을 추가해보세요")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(ReLinkColors.textTertiary)
            }
        }
    }

    private var emptyStateLarge: some View {
        VStack(spacing: 12) {
            Image(systemName: "gift")
                .font(.system(size: 40))
                .foregroundColor(ReLinkColors.textTertiary)
            Text("다가오는 기념일이 없어요")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ReLinkColors.textSecondary)
            Text("Re-Link에서 가족의 생일을 추가해보세요")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(ReLinkColors.textTertiary)
        }
    }
}

// MARK: - Widget Configuration

struct AnniversaryWidget: Widget {
    let kind: String = "AnniversaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AnniversaryProvider()) { entry in
            AnniversaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("다가오는 기념일")
        .description("가족의 생일과 기념일을 한눈에 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
