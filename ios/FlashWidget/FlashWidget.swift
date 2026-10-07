import AppIntents
import SwiftUI
import WidgetKit

private let appGroup = "group.com.example.flash"

// Một thẻ, khớp với JSON Dart gửi sang (mục 1.2).
struct WidgetCard: Decodable {
    let id: String
    let word: String
    let pronunciation: String
    let meaning: String
    let topicId: String
    let topicTitle: String
}

// Đọc/ghi bộ nhớ chung của App Group.
enum FlashStore {
    static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    static func cards() -> [WidgetCard] {
        guard let json = defaults?.string(forKey: "cards"),
              let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([WidgetCard].self, from: data)) ?? []
    }

    static func text(_ key: String) -> String { defaults?.string(forKey: key) ?? "" }

    static var index: Int {
        get { defaults?.integer(forKey: "w_index") ?? 0 }
        set { defaults?.set(newValue, forKey: "w_index") }
    }

    static var flipped: Bool {
        get { defaults?.bool(forKey: "w_flipped") ?? false }
        set { defaults?.set(newValue, forKey: "w_flipped") }
    }
}

// Nút →. Chạy ngay trong tiến trình widget, không mở app.
struct NextCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Từ tiếp theo"
    func perform() async throws -> some IntentResult {
        let count = FlashStore.cards().count
        if count > 0 {
            FlashStore.index = (FlashStore.index + 1) % count
            FlashStore.flipped = false
        }
        return .result() // xong hàm này, WidgetKit tự vẽ lại widget
    }
}

// Chạm vào thẻ để lật.
struct FlipCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Lật thẻ"
    func perform() async throws -> some IntentResult {
        FlashStore.flipped.toggle()
        return .result()
    }
}

struct FlashEntry: TimelineEntry {
    let date: Date
    let card: WidgetCard?
    let flipped: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FlashEntry {
        FlashEntry(date: .now, card: WidgetCard(id: "", word: "resilient", pronunciation: "/rɪˈzɪliənt/",
                                                meaning: "kiên cường", topicId: "", topicTitle: ""),
                   flipped: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (FlashEntry) -> Void) {
        completion(makeEntry())
    }

    // .never: không tự hẹn giờ; app gọi updateWidget() hoặc người dùng bấm nút thì mới vẽ lại.
    func getTimeline(in context: Context, completion: @escaping (Timeline<FlashEntry>) -> Void) {
        completion(Timeline(entries: [makeEntry()], policy: .never))
    }

    private func makeEntry() -> FlashEntry {
        let cards = FlashStore.cards()
        let card = cards.isEmpty ? nil : cards[FlashStore.index % cards.count]
        return FlashEntry(date: .now, card: card, flipped: FlashStore.flipped)
    }
}

struct FlashWidgetView: View {
    let entry: FlashEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Flash English").font(.caption).bold().foregroundStyle(.indigo)
                Spacer()
                if entry.card != nil {
                    Text(FlashStore.text("w_count_label")).font(.caption).foregroundStyle(.secondary)
                }
            }

            if let card = entry.card {
                HStack(alignment: .center) {
                    Button(intent: FlipCardIntent()) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.word).font(.title2).bold().lineLimit(1)
                            Text(entry.flipped ? card.pronunciation : FlashStore.text("w_tap_hint"))
                                .font(.caption).foregroundStyle(.secondary)
                            if entry.flipped {
                                Text(card.meaning).font(.subheadline).lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)

                    Button(intent: NextCardIntent()) {
                        Image(systemName: "arrow.right.circle.fill").font(.title)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.indigo)
                }
            } else {
                Spacer()
                Text(FlashStore.text("w_empty_title")).font(.headline)
                Text(FlashStore.text("w_empty_hint")).font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
        }
        .containerBackground(.background, for: .widget)
        .widgetURL(deepLink) // chạm vào chỗ không phải nút (ví dụ dòng tiêu đề) → mở app
    }

    // "homeWidget" trong query để gói home_widget nhận ra đường dẫn này là từ widget.
    private var deepLink: URL {
        var c = URLComponents()
        c.scheme = "flashwidget"
        c.host = "study"
        var items = [URLQueryItem(name: "homeWidget", value: nil)]
        if let card = entry.card {
            items.append(URLQueryItem(name: "topic", value: card.topicId))
            items.append(URLQueryItem(name: "title", value: card.topicTitle))
        }
        c.queryItems = items
        return c.url!
    }
}

struct FlashWidget: Widget {
    let kind = "FlashWidget" // trùng _iosName trong HomeWidgetService

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlashWidgetView(entry: entry)
        }
        .configurationDisplayName("Flash English")
        .description("Ôn từ vựng đến hạn ngay trên màn hình chính.")
        .supportedFamilies([.systemMedium])
    }
}
