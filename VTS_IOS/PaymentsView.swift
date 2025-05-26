import SwiftUI

struct PaymentsView: View {
    @ObservedObject var paymentService = PaymentService()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(paymentService.upcomingPayments) { payment in
                    PaymentRowView(payment: payment)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Upcoming Payments", displayMode: .inline)
            .onAppear {
                paymentService.fetchUpcomingPayments()
            }
        }
    }
}

struct PaymentRowView: View {
    let payment: Payment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(payment.description)
                    .font(.headline)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", payment.amount))")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Text("Due: \(formattedDate(payment.dueDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if payment.isPaid {
                Text("PAID")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.green)
                    .padding(.top, 2)
            } else {
                Text("PENDING")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.orange)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsView()
    }
}