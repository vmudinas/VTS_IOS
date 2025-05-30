import SwiftUI

public struct HistoryView: View {
    @ObservedObject var historyService = HistoryService()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedHistoryItems.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(formatSectionDate(date))) {
                        ForEach(groupedHistoryItems[date] ?? []) { item in
                            HistoryItemRow(historyItem: item)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("History", displayMode: .inline)
        }
    }
    
    private var groupedHistoryItems: [String: [HistoryItem]] {
        Dictionary(grouping: historyService.historyItems) { item in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: item.date)
        }
    }
    
    private func formatSectionDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
}

struct HistoryItemRow: View {
    let historyItem: HistoryItem
    
    var body: some View {
        HStack(spacing: 15) {
            activityIcon
                .font(.headline)
                .frame(width: 30, height: 30)
                .padding(5)
                .background(activityColor.opacity(0.2))
                .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(historyItem.description)
                    .font(.subheadline)
                    .lineLimit(2)
                
                Text(formattedTime(historyItem.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
    
    private var activityIcon: Image {
        switch historyItem.activityType {
        case .payment:
            return Image(systemName: "dollarsign.circle")
        case .issue:
            return Image(systemName: "exclamationmark.circle")
        case .videoUpload:
            return Image(systemName: "video")
        }
    }
    
    private var activityColor: Color {
        switch historyItem.activityType {
        case .payment:
            return .green
        case .issue:
            return .orange
        case .videoUpload:
            return .blue
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}