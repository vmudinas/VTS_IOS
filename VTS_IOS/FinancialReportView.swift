import SwiftUI
import UniformTypeIdentifiers

struct FinancialReportView: View {
    @ObservedObject var paymentService = PaymentService()
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var isShowingExportOptions = false
    @State private var exportData = ""
    @State private var showingShareSheet = false
    @State private var startDate = Date().startOfMonth()
    @State private var endDate = Date().endOfMonth()
    @State private var showCustomDatePicker = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
        case custom = "Custom"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Time frame picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedTimeFrame) { newValue in
                    updateDateRange()
                }
                
                if showCustomDatePicker {
                    VStack {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.horizontal)
                        
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Summary section
                        FinancialSummaryCard(
                            startDate: startDate,
                            endDate: endDate,
                            income: paymentService.calculateIncome(from: startDate, to: endDate),
                            expenses: paymentService.calculateExpenses(from: startDate, to: endDate),
                            profitLoss: paymentService.calculateProfitLoss(from: startDate, to: endDate)
                        )
                        .padding(.horizontal)
                        
                        // Income breakdown
                        let incomeCategories = paymentService.incomeByCategory(from: startDate, to: endDate)
                        if !incomeCategories.isEmpty {
                            FinancialCategoryBreakdownCard(
                                title: "Income Breakdown",
                                categories: incomeCategories,
                                total: paymentService.calculateIncome(from: startDate, to: endDate)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Expense breakdown
                        let expenseCategories = paymentService.expensesByCategory(from: startDate, to: endDate)
                        if !expenseCategories.isEmpty {
                            FinancialCategoryBreakdownCard(
                                title: "Expense Breakdown",
                                categories: expenseCategories,
                                total: paymentService.calculateExpenses(from: startDate, to: endDate)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Transactions list
                        RecentTransactionsCard(
                            transactions: paymentService.getTransactions(from: startDate, to: endDate),
                            showAllAction: {}
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                Button(action: {
                    exportData = paymentService.exportToCSV(from: startDate, to: endDate)
                    showingShareSheet = true
                }) {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("Financial Reports", displayMode: .inline)
            .onAppear {
                updateDateRange()
            }
            .sheet(isPresented: $showingShareSheet) {
                if #available(iOS 16.0, *) {
                    ShareSheet(items: [exportData], excludedActivityTypes: nil)
                } else {
                    // For older iOS versions
                    ActivityViewController(activityItems: [exportData as Any], applicationActivities: nil)
                }
            }
        }
    }
    
    private func updateDateRange() {
        switch selectedTimeFrame {
        case .week:
            startDate = Date().startOfWeek()
            endDate = Date().endOfWeek()
        case .month:
            startDate = Date().startOfMonth()
            endDate = Date().endOfMonth()
        case .quarter:
            startDate = Date().startOfQuarter()
            endDate = Date().endOfQuarter()
        case .year:
            startDate = Date().startOfYear()
            endDate = Date().endOfYear()
        case .custom:
            showCustomDatePicker = true
            return
        }
        showCustomDatePicker = false
    }
}

// Helper view for financial summary
struct FinancialSummaryCard: View {
    let startDate: Date
    let endDate: Date
    let income: Double
    let expenses: Double
    let profitLoss: Double
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) to \(formatter.string(from: endDate))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Financial Summary")
                .font(.headline)
                .padding(.bottom, 4)
            
            Text(dateRangeText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            HStack(spacing: 20) {
                FinancialMetric(title: "Income", value: income, color: .green)
                FinancialMetric(title: "Expenses", value: expenses, color: .red)
                FinancialMetric(title: "Profit/Loss", value: profitLoss, color: profitLoss >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Helper view for individual metrics
struct FinancialMetric: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("$\(String(format: "%.2f", value))")
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Helper view for category breakdown
struct FinancialCategoryBreakdownCard: View {
    let title: String
    let categories: [PaymentCategory: Double]
    let total: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(Array(categories.keys.sorted { categories[$0]! > categories[$1]! }), id: \.self) { category in
                if let amount = categories[category] {
                    HStack {
                        Text(category.rawValue)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", amount))")
                            .bold()
                        
                        Text("(\(String(format: "%.1f%%", (amount / total) * 100)))")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    ProgressBar(value: CGFloat(amount / total))
                        .frame(height: 6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Progress bar view
struct ProgressBar: View {
    let value: CGFloat // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: geometry.size.width * value, height: geometry.size.height)
                    .foregroundColor(.blue)
            }
        }
        .cornerRadius(45)
    }
}

// Recent transactions view
struct RecentTransactionsCard: View {
    let transactions: [Payment]
    let showAllAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transactions")
                    .font(.headline)
                
                Spacer()
                
                if transactions.count > 5 {
                    Button("See All") {
                        showAllAction()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 4)
            
            if transactions.isEmpty {
                Text("No transactions in this period")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(transactions.prefix(5)) { transaction in
                    TransactionListItem(transaction: transaction)
                    
                    if transaction.id != transactions.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Transaction list item
struct TransactionListItem: View {
    let transaction: Payment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(formattedDate(transaction.dueDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", transaction.amount))")
                    .font(.subheadline)
                    .foregroundColor(transaction.category?.isIncome == true ? .green : .red)
                
                Text(transaction.category?.rawValue ?? "Uncategorized")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Share sheet for iOS 16+
@available(iOS 16.0, *)
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Activity view controller for iOS 15 and earlier
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

// Date extensions for financial reporting time frames
extension Date {
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfWeek() -> Date {
        var components = DateComponents()
        components.day = 6
        return Calendar.current.date(byAdding: components, to: startOfWeek())!
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth())!
    }
    
    func startOfQuarter() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let quarter = ((month - 1) / 3) * 3 + 1
        var components = calendar.dateComponents([.year], from: self)
        components.month = quarter
        components.day = 1
        return calendar.date(from: components)!
    }
    
    func endOfQuarter() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let quarter = ((month - 1) / 3) * 3 + 3
        var components = calendar.dateComponents([.year], from: self)
        components.month = quarter + 1
        components.day = 0
        return calendar.date(from: components)!
    }
    
    func startOfYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfYear() -> Date {
        var components = DateComponents()
        components.year = 1
        components.day = -1
        return Calendar.current.date(byAdding: components, to: startOfYear())!
    }
}

struct FinancialReportView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialReportView()
    }
}