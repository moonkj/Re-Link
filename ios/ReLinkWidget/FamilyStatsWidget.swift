import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct FamilyStatsEntry: TimelineEntry {
    let date: Date
    let nodeCount: Int
    let memoryCount: Int
}

// MARK: - Timeline Provider

struct FamilyStatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> FamilyStatsEntry {
        FamilyStatsEntry(date: Date(), nodeCount: 12, memoryCount: 48)
    }

    func getSnapshot(in context: Context, completion: @escaping (FamilyStatsEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FamilyStatsEntry>) -> Void) {
        let entry = loadEntry()

        // Refresh every 6 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> FamilyStatsEntry {
        let defaults = ReLinkUserDefaults.shared

        let nodeCount = defaults?.integer(forKey: "family_node_count") ?? 0
        let memoryCount = defaults?.integer(forKey: "family_memory_count") ?? 0

        return FamilyStatsEntry(
            date: Date(),
            nodeCount: nodeCount,
            memoryCount: memoryCount
        )
    }
}

// MARK: - Widget Views

struct FamilyStatsWidgetEntryView: View {
    var entry: FamilyStatsEntry
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

    // MARK: Small — Node count + memory count

    private var smallView: some View {
        ZStack {
            ReLinkColors.backgroundDark

            if entry.nodeCount == 0 && entry.memoryCount == 0 {
                emptyStateSmall
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "tree.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ReLinkColors.primaryMint)
                        Text("가족 트리")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ReLinkColors.textSecondary)
                        Spacer()
                    }

                    Spacer()

                    // Node count
                    statBlock(
                        icon: "person.2.fill",
                        value: "\(entry.nodeCount)",
                        label: "가족",
                        color: ReLinkColors.primaryMint
                    )

                    // Memory count
                    statBlock(
                        icon: "heart.fill",
                        value: "\(entry.memoryCount)",
                        label: "기억",
                        color: ReLinkColors.primaryBlue
                    )
                }
                .padding(16)
            }
        }
        .widgetURL(URL(string: "relink://canvas"))
    }

    // MARK: Medium — Node count + memory count + branding

    private var mediumView: some View {
        ZStack {
            ReLinkColors.backgroundDark

            if entry.nodeCount == 0 && entry.memoryCount == 0 {
                emptyStateMedium
            } else {
                HStack(spacing: 0) {
                    // Left: Stats
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "tree.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(ReLinkColors.primaryMint)
                            Text("가족 트리")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(ReLinkColors.textSecondary)
                        }

                        Spacer()

                        HStack(spacing: 24) {
                            statColumn(
                                icon: "person.2.fill",
                                value: "\(entry.nodeCount)",
                                label: "가족",
                                color: ReLinkColors.primaryMint
                            )

                            statColumn(
                                icon: "heart.fill",
                                value: "\(entry.memoryCount)",
                                label: "기억",
                                color: ReLinkColors.primaryBlue
                            )
                        }

                        Spacer()
                    }
                    .padding(16)

                    Spacer()

                    // Right: Branding
                    VStack {
                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            ReLinkColors.primaryMint.opacity(0.15),
                                            ReLinkColors.primaryBlue.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            VStack(spacing: 6) {
                                Image(systemName: "tree.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(ReLinkColors.primaryMint)

                                Text("Re-Link")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ReLinkColors.textPrimary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.trailing, 16)
                }
            }
        }
        .widgetURL(URL(string: "relink://canvas"))
    }

    // MARK: Stat Components

    private func statBlock(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 16)

            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(ReLinkColors.textPrimary)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ReLinkColors.textTertiary)
        }
    }

    private func statColumn(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(ReLinkColors.textPrimary)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ReLinkColors.textTertiary)
        }
    }

    // MARK: Empty States

    private var emptyStateSmall: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2")
                .font(.system(size: 28))
                .foregroundColor(ReLinkColors.textTertiary)
            Text("가족을\n추가해보세요")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ReLinkColors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var emptyStateMedium: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 32))
                .foregroundColor(ReLinkColors.textTertiary)
            VStack(alignment: .leading, spacing: 4) {
                Text("가족 트리가 비어있어요")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ReLinkColors.textSecondary)
                Text("Re-Link에서 가족을 추가해보세요")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(ReLinkColors.textTertiary)
            }
            Spacer()
        }
        .padding(16)
    }
}

// MARK: - Widget Configuration

struct FamilyStatsWidget: Widget {
    let kind: String = "FamilyStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FamilyStatsProvider()) { entry in
            FamilyStatsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("가족 트리")
        .description("나의 가족 트리 현황을 한눈에 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
