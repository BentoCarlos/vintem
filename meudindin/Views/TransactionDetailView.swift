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

        VStack{
            HStack(spacing: 16) {
                Text("Transação  #\(transactionId)")
                Text("\(transaction.name)")
                Text(transaction.amount_cents ?? 0, format: .currency(code: "BRL"))

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
