import SwiftUI

struct PaymentsView: View {
    @ObservedObject var paymentService = PaymentService()
    @State private var isShowingPaymentSheet = false
    @State private var isShowingHistorySheet = false
    @State private var selectedPayment: Payment? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Payment View", selection: $isShowingHistorySheet) {
                    Text("Upcoming").tag(false)
                    Text("History").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if !isShowingHistorySheet {
                    List {
                        ForEach(paymentService.upcomingPayments) { payment in
                            PaymentRowView(payment: payment)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedPayment = payment
                                    isShowingPaymentSheet = true
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    List {
                        ForEach(paymentService.paymentHistory) { payment in
                            PaymentHistoryRowView(payment: payment)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationBarTitle("Payments", displayMode: .inline)
            .sheet(isPresented: $isShowingPaymentSheet) {
                if let payment = selectedPayment {
                    PaymentDetailView(paymentService: paymentService, payment: payment, isPresented: $isShowingPaymentSheet)
                }
            }
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
            
            HStack {
                if payment.isPaid {
                    Text("PAID")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.green)
                } else {
                    Text("PENDING")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                if payment.isRecurring {
                    HStack {
                        Image(systemName: "repeat")
                            .font(.caption)
                        Text(payment.paymentFrequency.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 5)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PaymentHistoryRowView: View {
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
            
            Text("Paid: \(formattedDate(payment.dueDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("PAID")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.green)
                
                if let method = payment.paymentMethod {
                    Spacer()
                    
                    Text("via \(method.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if payment.hasRefund, let refundAmount = payment.refundAmount {
                    Spacer()
                    
                    Text("Refunded: $\(String(format: "%.2f", refundAmount))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 5)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PaymentDetailView: View {
    @ObservedObject var paymentService: PaymentService
    let payment: Payment
    @Binding var isPresented: Bool
    
    @State private var selectedPaymentMethod: PaymentMethod = .stripe
    @State private var isRecurring: Bool = false
    @State private var selectedFrequency: PaymentFrequency = .monthly
    @State private var isProcessingPayment = false
    @State private var paymentComplete = false
    @State private var showRecurringOptions = false
    @State private var refundAmount: String = ""
    @State private var showRefundSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payment Details")) {
                    HStack {
                        Text("Description")
                        Spacer()
                        Text(payment.description)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        Text("$\(String(format: "%.2f", payment.amount))")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Due Date")
                        Spacer()
                        Text(formattedDate(payment.dueDate))
                            .foregroundColor(.secondary)
                    }
                    
                    if payment.isRecurring {
                        HStack {
                            Text("Recurring")
                            Spacer()
                            Text(payment.paymentFrequency.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if !payment.isPaid {
                    Section(header: Text("Payment Method")) {
                        Picker("Select Payment Method", selection: $selectedPaymentMethod) {
                            ForEach(PaymentMethod.allCases, id: \.self) { method in
                                Text(method.rawValue).tag(method)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Toggle("Set as recurring payment", isOn: $showRecurringOptions.animation())
                        
                        if showRecurringOptions {
                            Picker("Frequency", selection: $selectedFrequency) {
                                ForEach(PaymentFrequency.allCases.filter { $0 != .oneTime }, id: \.self) { frequency in
                                    Text(frequency.rawValue).tag(frequency)
                                }
                            }
                        }
                        
                        Button(action: {
                            processPayment()
                        }) {
                            if isProcessingPayment {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Pay Now")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(isProcessingPayment)
                    }
                } else if payment.isPaid {
                    Section(header: Text("Payment Information")) {
                        if let method = payment.paymentMethod {
                            HStack {
                                Text("Paid with")
                                Spacer()
                                Text(method.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if !payment.hasRefund {
                            Button("Request Refund") {
                                refundAmount = String(format: "%.2f", payment.amount)
                                showRefundSheet = true
                            }
                            .foregroundColor(.red)
                        } else if let refundAmount = payment.refundAmount {
                            HStack {
                                Text("Refunded Amount")
                                Spacer()
                                Text("$\(String(format: "%.2f", refundAmount))")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Payment Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
            .alert(isPresented: $paymentComplete) {
                Alert(
                    title: Text("Payment Complete"),
                    message: Text("Your payment has been processed successfully."),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                    }
                )
            }
            .sheet(isPresented: $showRefundSheet) {
                RefundView(
                    payment: payment,
                    paymentService: paymentService,
                    refundAmount: $refundAmount,
                    isPresented: $showRefundSheet,
                    parentSheet: $isPresented
                )
            }
        }
    }
    
    private func processPayment() {
        isProcessingPayment = true
        
        // Set up recurring payment if needed
        if showRecurringOptions {
            paymentService.setupRecurringPayment(payment: payment, frequency: selectedFrequency)
        }
        
        // Process payment
        paymentService.makePayment(payment: payment, paymentMethod: selectedPaymentMethod) { success in
            isProcessingPayment = false
            if success {
                paymentComplete = true
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct RefundView: View {
    let payment: Payment
    @ObservedObject var paymentService: PaymentService
    @Binding var refundAmount: String
    @Binding var isPresented: Bool
    @Binding var parentSheet: Bool
    
    @State private var isProcessing = false
    @State private var refundComplete = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Refund Details")) {
                    HStack {
                        Text("Original Payment")
                        Spacer()
                        Text("$\(String(format: "%.2f", payment.amount))")
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Refund Amount", text: $refundAmount)
                        .keyboardType(.decimalPad)
                }
                
                Button(action: {
                    processRefund()
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Process Refund")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(isProcessing)
            }
            .navigationBarTitle("Request Refund", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .alert(isPresented: $refundComplete) {
                Alert(
                    title: Text("Refund Processed"),
                    message: Text("Your refund request has been processed."),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                        parentSheet = false
                    }
                )
            }
        }
    }
    
    private func processRefund() {
        guard let amount = Double(refundAmount), amount > 0 else { return }
        
        isProcessing = true
        paymentService.refundPayment(payment: payment, amount: amount) { success in
            isProcessing = false
            if success {
                refundComplete = true
            }
        }
    }
}

struct PaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsView()
    }
}