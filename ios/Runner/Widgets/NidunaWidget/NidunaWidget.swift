import WidgetKit
import SwiftUI

// Bridge to the App Group's shared UserDefaults. The main Flutter app
// writes widget data to this group via HomeWidget.saveWidgetData; the
// widget extension reads from the same suite.
private enum AppGroup {
  static let id = "group.com.niduna.currencyConverter"
  static let store = UserDefaults(suiteName: id)
}

struct NidunaEntry: TimelineEntry {
  let date: Date
  let baseCode: String
  let quoteCode: String
  let amountText: String
  let convertedText: String
  let updatedText: String
}

struct NidunaProvider: TimelineProvider {
  func placeholder(in context: Context) -> NidunaEntry {
    NidunaEntry(
      date: Date(),
      baseCode: "USD",
      quoteCode: "EUR",
      amountText: "100 USD",
      convertedText: "= 92.50 EUR",
      updatedText: "Updated today"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (NidunaEntry) -> Void) {
    completion(readEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<NidunaEntry>) -> Void) {
    let entry = readEntry()
    // Refresh every 4 hours. The main app calls
    // WidgetCenter.shared.reloadAllTimelines() whenever it pushes fresh
    // data, so the system also gets a poke to refresh sooner.
    let next = Date().addingTimeInterval(4 * 60 * 60)
    completion(Timeline(entries: [entry], policy: .after(next)))
  }

  private func readEntry() -> NidunaEntry {
    let baseCode = AppGroup.store?.string(forKey: "baseCode") ?? "USD"
    let quoteCode = AppGroup.store?.string(forKey: "quoteCode") ?? "EUR"
    // amount + rate are sent as strings by the Dart side (see
    // home_widget_provider.dart) because raw UserDefaults has no Double
    // getter that's safe across types. We only need them as numbers
    // for the local fallback when the app hasn't pre-formatted
    // `convertedAmount`.
    let amount = Double(AppGroup.store?.string(forKey: "amount") ?? "") ?? 100.0
    let rate = Double(AppGroup.store?.string(forKey: "rate") ?? "") ?? 0.0
    let convertedAmount = AppGroup.store?.string(forKey: "convertedAmount") ?? ""
    let updatedAt = AppGroup.store?.string(forKey: "updatedAt") ?? ""

    return NidunaEntry(
      date: Date(),
      baseCode: baseCode,
      quoteCode: quoteCode,
      amountText: String(format: "%.0f %@", amount, baseCode),
      convertedText: convertedAmount.isEmpty
        ? String(format: "= %.2f %@", amount * rate, quoteCode)
        : "= \(convertedAmount)",
      updatedText: updatedAt.isEmpty ? "" : "Updated \(updatedAt)"
    )
  }
}

struct NidunaWidgetEntryView: View {
  var entry: NidunaEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(entry.amountText)
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(Color(red: 0.11, green: 0.10, blue: 0.09))

      Text(entry.convertedText)
        .font(.system(size: 24, weight: .bold))
        .foregroundColor(Color(red: 0.11, green: 0.10, blue: 0.09))

      Text(entry.updatedText)
        .font(.system(size: 12))
        .foregroundColor(Color(red: 0.47, green: 0.44, blue: 0.42))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .padding(16)
    .background(Color(red: 1.0, green: 0.98, blue: 0.92))
    .cornerRadius(16)
  }
}

struct NidunaWidget: Widget {
  let kind = "NidunaCurrencyWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: NidunaProvider()) { entry in
      NidunaWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Niduna Currency")
    .description("Quick glance at your top currency conversion rate")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// WidgetBundle wrapper. iOS 17+ WidgetKit requires a `@main`-annotated
// WidgetBundle that exposes one or more Widgets — a bare `Widget` struct
// in the extension's principal slot gets a "Invalid placeholder
// attributes" error at install time.
@main
struct NidunaWidgetBundle: WidgetBundle {
  var body: some Widget {
    NidunaWidget()
  }
}
