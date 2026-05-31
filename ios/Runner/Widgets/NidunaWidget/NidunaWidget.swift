import WidgetKit
import SwiftUI

struct NidunaEntry: TimelineEntry {
    let date: Date
    let baseCode: String
    let quoteCode: String
    let amountText: String
    let convertedText: String
    let updatedText: String
}

struct NidunaProvider: IntentTimelineProvider {
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
        let entry = readEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NidunaEntry>) -> Void) {
        let entry = readEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(14400)))
        completion(timeline)
    }

    private func readEntry() -> NidunaEntry {
        guard let data = HomeWidget.getWidgetData(keys: [
            "baseCode", "quoteCode", "amount", "convertedAmount", "updatedAt"
        ]) else {
            return placeholder(in: Context())
        }
        let baseCode = data["baseCode"] as? String ?? "USD"
        let quoteCode = data["quoteCode"] as? String ?? "EUR"
        let amount = data["amount"] as? Double ?? 100.0
        let convertedAmount = data["convertedAmount"] as? String ?? ""
        let updatedAt = data["updatedAt"] as? String ?? ""

        return NidunaEntry(
            date: Date(),
            baseCode: baseCode,
            quoteCode: quoteCode,
            amountText: String(format: "%.0f %@", amount, baseCode),
            convertedText: convertedAmount.isEmpty
                ? String(format: "= %.2f %@", amount * (data["rate"] as? Double ?? 0.0), quoteCode)
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
