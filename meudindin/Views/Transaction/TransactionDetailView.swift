//
//  TransactionDetailView.swift
//  meudindin
//
//  Created by Bento Carlos on 09/12/25.
//

import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    let transaction: Transaction

    var body: some View {
        let transactionId = transaction.id != nil ? String(transaction.id!) : ""
        var transactionValue: Double? {
            guard let cents = transaction.amount_cents else { return nil }
            return Double(cents) / 100.0
        }

        VStack{
            HStack(spacing: 16) {
                Text("Transação  #\(transactionId)")
                Text("\(transaction.name)")

                if (transactionValue != nil) {
                    Text(transactionValue!, format: .currency(code: "BRL"))
                } else {
                    Text("N/A")
                }

                if (transaction.payment_type != nil) {
                    PaymentTypeView(buttonType: transaction.payment_type!)
                }
            }
            .padding(16)

            Button("Ok") {
                dismiss()
            }
            .buttonStyle(.glassProminent)
        }
        .padding(16)
    }
}

#Preview {
    let transaction = Transaction(id: 123, name: "Test", amount_cents: 10000, payment_type: .credito)
    TransactionDetailView(transaction: transaction)
}
