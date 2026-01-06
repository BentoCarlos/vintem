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
        VStack{
            HStack(spacing: 16) {
                Text("Transação  #\(transaction.id)")
                Text("\(transaction.name)")
                Text(transaction.value, format: .currency(code: "BRL"))

                PaymentTypeView(buttonType: transaction.paymentType)
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
    let transaction = Transaction(id: 123, name: "Test", value: 100.00, paymentType: .credito)
    TransactionDetailView(transaction: transaction)
}
