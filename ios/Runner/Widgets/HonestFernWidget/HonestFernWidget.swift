import WidgetKit
import SwiftUI

// Shared store written by the Flutter app via HomeWidget.saveWidgetData.
private enum AppGroup {
  static let id = "group.com.honestfern.currencyConverter"
  static let store = UserDefaults(suiteName: id)

  // Reads the shared defaults plist straight from the App Group container.
  // UserDefaults(suiteName:) does not reliably surface another process's
  // app-group writes on the iOS Simulator (cfprefsd serves a stale, empty
  // cache), so the widget reads the backing plist file directly. This is the
  // source of truth; `store` is only a fallback.
  static func sharedDict() -> [String: Any] {
    guard let url = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: id) else { return [:] }
    let plistURL = url.appendingPathComponent("Library/Preferences/\(id).plist")
    return (NSDictionary(contentsOf: plistURL) as? [String: Any]) ?? [:]
  }
}

// Honest Fern palette — mirrors the Android widget (android/.../widget_layout.xml,
// widget_background.xml, widget_icon_circle.xml) so both platforms match.
private enum Palette {
  static let paper  = Color(red: 1.0,  green: 0.976, blue: 0.925) // #FFF9EC card
  static let ink    = Color(red: 0.09, green: 0.11,  blue: 0.08)  // #171D14
  static let muted  = Color(red: 0.37, green: 0.42,  blue: 0.35)  // #5F6A58
  static let up     = Color(red: 0.44, green: 0.55,  blue: 0.29)  // #6F8C49
  static let down   = Color(red: 0.86, green: 0.40,  blue: 0.26)  // #DC6543
  static let circle = Color(red: 0.157, green: 0.373, blue: 0.231) // #285F3B dark green
  static let divider = Color(red: 0.157, green: 0.373, blue: 0.231).opacity(0.14) // #24285F3B
}

struct HonestFernPair {
  let code: String
  let symbol: String
  let value: String
  let trend: String   // up | down | flat | none
  let change: String  // e.g. "0.12%" (may be empty)
}

struct HonestFernEntry: TimelineEntry {
  let date: Date
  let amountLabel: String
  let updatedLabel: String
  let pairs: [HonestFernPair]
}

struct HonestFernProvider: TimelineProvider {
  func placeholder(in context: Context) -> HonestFernEntry {
    HonestFernEntry(
      date: Date(),
      amountLabel: "100 USD",
      updatedLabel: "Updated today",
      pairs: [
        HonestFernPair(code: "EUR", symbol: "€", value: "86.34", trend: "down", change: "0.12%"),
        HonestFernPair(code: "GBP", symbol: "£", value: "74.57", trend: "up", change: "0.06%"),
        HonestFernPair(code: "BTC", symbol: "₿", value: "0.00155", trend: "none", change: ""),
      ]
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (HonestFernEntry) -> Void) {
    completion(readEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HonestFernEntry>) -> Void) {
    let entry = readEntry()
    // The app pokes WidgetCenter on every data push. If we read no data yet
    // (the app just wrote it and the shared file hasn't been flushed to disk),
    // ask for a refresh soon so the widget self-heals; otherwise refresh in 4h.
    let next = entry.pairs.isEmpty
      ? Date().addingTimeInterval(60)
      : Date().addingTimeInterval(4 * 60 * 60)
    completion(Timeline(entries: [entry], policy: .after(next)))
  }

  private func readEntry() -> HonestFernEntry {
    let shared = AppGroup.sharedDict()
    let store = AppGroup.store

    func str(_ key: String) -> String {
      (shared[key] as? String) ?? store?.string(forKey: key) ?? ""
    }
    func flag(_ key: String) -> Bool {
      if let b = shared[key] as? Bool { return b }
      return store?.bool(forKey: key) ?? false
    }

    var pairs: [HonestFernPair] = []
    for i in 0..<3 {
      let prefix = "pair_\(i)_"
      let value = str("\(prefix)value")
      guard flag("\(prefix)visible"), !value.isEmpty else { continue }
      let trend = str("\(prefix)trend")
      pairs.append(
        HonestFernPair(
          code: str("\(prefix)code"),
          symbol: str("\(prefix)symbol"),
          value: value,
          trend: trend.isEmpty ? "none" : trend,
          change: str("\(prefix)change")
        )
      )
    }
    return HonestFernEntry(
      date: Date(),
      amountLabel: str("amountLabel"),
      updatedLabel: str("updatedLabel"),
      pairs: pairs
    )
  }
}

private struct WidgetDivider: View {
  var body: some View {
    Rectangle().fill(Palette.divider).frame(height: 1)
  }
}

private struct PairRow: View {
  let pair: HonestFernPair

  private var trendColor: Color {
    switch pair.trend {
    case "up": return Palette.up
    case "down": return Palette.down
    default: return Palette.muted
    }
  }

  private var trendArrow: String {
    switch pair.trend {
    case "up": return "↑"
    case "down": return "↓"
    default: return ""
    }
  }

  var body: some View {
    HStack(spacing: 8) {
      // Symbol in a solid dark-green circle (mirrors widget_icon_circle.xml).
      ZStack {
        Circle().fill(Palette.circle)
        Text(pair.symbol)
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(.white)
          .minimumScaleFactor(0.6)
          .lineLimit(1)
          .padding(.horizontal, 2)
      }
      .frame(width: 24, height: 24)

      Text(pair.code)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(Palette.ink)

      Spacer(minLength: 4)

      Text(pair.value)
        .font(.system(size: 22, weight: .bold))
        .foregroundColor(Palette.ink)
        .lineLimit(1)
        .minimumScaleFactor(0.5)

      if !trendArrow.isEmpty, !pair.change.isEmpty {
        Text("\(trendArrow) \(pair.change)")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(trendColor)
          .fixedSize()
      }
    }
  }
}

struct HonestFernWidgetEntryView: View {
  var entry: HonestFernEntry

  var body: some View {
    if entry.pairs.isEmpty {
      VStack(alignment: .leading, spacing: 4) {
        Text("Honest Fern").font(.system(size: 16, weight: .heavy)).foregroundColor(Palette.ink)
        Text("Open to load").font(.system(size: 12)).foregroundColor(Palette.muted)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .padding(16)
      .background(Palette.paper)
    } else {
      VStack(alignment: .leading, spacing: 0) {
        // Header: amount (left) + updated (right) — matches the Android layout.
        HStack(alignment: .firstTextBaseline) {
          Text(entry.amountLabel.isEmpty ? "Honest Fern" : entry.amountLabel)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Palette.ink)
            .lineLimit(1)
          Spacer(minLength: 8)
          if !entry.updatedLabel.isEmpty {
            Text(entry.updatedLabel)
              .font(.system(size: 11))
              .foregroundColor(Palette.muted)
              .lineLimit(1)
          }
        }

        WidgetDivider().padding(.top, 12).padding(.bottom, 8)

        ForEach(Array(entry.pairs.enumerated()), id: \.offset) { index, pair in
          PairRow(pair: pair)
          if index < entry.pairs.count - 1 {
            WidgetDivider().padding(.vertical, 10)
          }
        }
        Spacer(minLength: 0)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .padding(16)
      .background(Palette.paper)
    }
  }
}

struct HonestFernWidget: Widget {
  let kind = "HonestFernCurrencyWidget" // MUST match iOSName in home_widget_provider.dart

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HonestFernProvider()) { entry in
      if #available(iOS 17.0, *) {
        HonestFernWidgetEntryView(entry: entry).containerBackground(Palette.paper, for: .widget)
      } else {
        HonestFernWidgetEntryView(entry: entry)
      }
    }
    .configurationDisplayName("Honest Fern Currency")
    .description("Your top currency pairs at a glance")
    .supportedFamilies([.systemMedium])
  }
}

@main
struct HonestFernWidgetBundle: WidgetBundle {
  var body: some Widget { HonestFernWidget() }
}
