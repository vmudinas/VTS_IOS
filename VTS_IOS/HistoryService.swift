import Foundation

class HistoryService: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    
    init() {
        // Load sample data
        loadSampleHistoryItems()
    }
    
    func loadSampleHistoryItems() {
        // Generate some sample history items
        historyItems = [
            HistoryItem(
                activityType: .payment,
                description: "Rent payment processed for May",
                date: Date().addingTimeInterval(-86400 * 3) // 3 days ago
            ),
            HistoryItem(
                activityType: .issue,
                description: "Maintenance request for leaking faucet completed",
                date: Date().addingTimeInterval(-86400 * 5) // 5 days ago
            ),
            HistoryItem(
                activityType: .document,
                description: "Lease renewal agreement uploaded",
                date: Date().addingTimeInterval(-86400 * 10) // 10 days ago
            )
        ]
    }
    
    func addHistoryItem(item: HistoryItem) {
        historyItems.insert(item, at: 0)
    }
    
    func getHistoryForItem(itemId: UUID) -> [HistoryItem] {
        return historyItems.filter { $0.relatedItemId == itemId }
    }
    
    func clearHistory() {
        historyItems.removeAll()
    }
}