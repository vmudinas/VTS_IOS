import SwiftUI

public struct PaymentsView: View {
    @ObservedObject var paymentService = PaymentService()
    @State private var isShowingPaymentSheet = false
    @State private var isShowingHistorySheet = false
    @State private var selectedPayment: Payment? = nil
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(localization.localized("payments"), selection: $isShowingHistorySheet) {
                    Text(localization.localized("upcoming")).tag(false)
                    Text(localization.localized("history")).tag(true)
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
            .navigationBarTitle(localization.localized("payments"), displayMode: .inline)
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
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(payment.description)
                    .font(.headline)
                
                Spacer()
                
                Text(localization.formatCurrency(payment.amount))
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Text("Due: \(localization.formatDate(payment.dueDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                if payment.isPaid {
                    Text(localization.localized("paid"))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.green)
                } else {
                    Text(localization.localized("pending"))
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
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(payment.description)
                    .font(.headline)
                
                Spacer()
                
                Text(localization.formatCurrency(payment.amount))
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Text("\(localization.localized("paid")): \(localization.formatDate(payment.dueDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(localization.localized("paid"))
                    .font(.caption)
                    .bold()
                    .foregroundColor(.green)
                
                if let method = payment.paymentMethod {
                    Spacer()
                    
                    Text("\(localization.localized("via")) \(method.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if payment.hasRefund, let refundAmount = payment.refundAmount {
                    Spacer()
                    
                    Text("\(localization.localized("refunded")): \(localization.formatCurrency(refundAmount))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 2)
            
            // Show refund details if applicable
            if payment.hasRefund, let refundIssuedBy = payment.refundIssuedBy, let refundReason = payment.refundReason {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Refund by: \(refundIssuedBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Reason: \(refundReason)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if let refundDate = payment.refundDate {
                        Text("Date: \(formattedDate(refundDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
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

struct PaymentDetailView: View {
    @ObservedObject var paymentService: PaymentService
    let payment: Payment
    @Binding var isPresented: Bool
    @ObservedObject private var localization = LocalizationManager.shared
    
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
                        Text(localization.localized("amount"))
                        Spacer()
                        Text(localization.formatCurrency(payment.amount))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(localization.localized("due_date"))
                        Spacer()
                        Text(localization.formatDate(payment.dueDate))
                            .foregroundColor(.secondary)
                    }
                    
                    if payment.isRecurring {
                        HStack {
                            Text(localization.localized("recurring"))
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
                            Button("Issue Refund (Landlords Only)") {
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
                            
                            if let refundIssuedBy = payment.refundIssuedBy {
                                HStack {
                                    Text("Issued By")
                                    Spacer()
                                    Text(refundIssuedBy)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let refundReason = payment.refundReason {
                                HStack {
                                    Text("Reason")
                                    Spacer()
                                    Text(refundReason)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            
                            if let refundDate = payment.refundDate {
                                HStack {
                                    Text("Refund Date")
                                    Spacer()
                                    Text(formattedDate(refundDate))
                                        .foregroundColor(.secondary)
                                }
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
    @State private var landlordId: String = "landlord123" // In a real app, this would be fetched from user credentials
    @State private var refundReason: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Landlord Refund Management")) {
                    HStack {
                        Text("Landlord ID")
                        Spacer()
                        Text(landlordId)
                            .foregroundColor(.secondary)
                    }
                
                    HStack {
                        Text("Original Payment")
                        Spacer()
                        Text("$\(String(format: "%.2f", payment.amount))")
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Refund Amount", text: $refundAmount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Reason for Refund", text: $refundReason)
                        .autocapitalization(.none)
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
                .disabled(isProcessing || refundReason.isEmpty)
            }
            .navigationBarTitle("Issue Refund", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .alert(isPresented: $refundComplete) {
                Alert(
                    title: Text("Refund Processed"),
                    message: Text("The refund has been processed and the tenant has been notified."),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                        parentSheet = false
                    }
                )
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func processRefund() {
        guard let amount = Double(refundAmount), amount > 0 else { 
            errorMessage = "Please enter a valid refund amount"
            showError = true
            return
        }
        
        guard !refundReason.isEmpty else {
            errorMessage = "Please provide a reason for the refund"
            showError = true
            return
        }
        
        isProcessing = true
        paymentService.refundPayment(payment: payment, amount: amount, issuedBy: landlordId, reason: refundReason) { success in
            isProcessing = false
            if success {
                refundComplete = true
            } else {
                errorMessage = "Failed to process the refund. Please try again."
                showError = true
            }
        }
    }
}

struct PaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsView()
    }
}
