//
//  TransactionDetailView.swift
//  meudindin
//
//  Created by Bento Carlos on 09/12/25.
//

import SwiftUI
import Supabase

struct TransactionUpdate: Codable {
    let name: String
}

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var supabase: SupabaseManager

    @State var transaction: Transaction
    @State var transactionName: String

    init(transaction: Transaction) {
        _transaction = State(initialValue: transaction)
        _transactionName = State(initialValue: transaction.name)
    }

    var body: some View {
        let transactionId = transaction.id != nil ? String(transaction.id!) : ""
        var transactionValue: Double? {
            guard let cents = transaction.amount_cents else { return nil }
            return Double(cents) / 100.0
        }

        VStack{
            VStack(spacing: 16) {
                Text("Transação  #\(transactionId)")
                TextField("", text: $transactionName)

                if (transactionValue != nil) {
                    Text(transactionValue!, format: .currency(code: "BRL"))
                } else {
                    Text("N/A")
                }

                if (transaction.payment_type != nil) {
                    PaymentTypeView(buttonType: transaction.payment_type!.toEnum!)
                }
            }
            .padding(16)

            HStack {
                Button("Voltar") {
                    dismiss()
                }

                Button("Atualizar") {
                    let updatedTransaction = TransactionUpdate(name: transactionName)

                    Task {
                        do {
                            let res = try await supabase.client
                                .from("transactions")
                                .update(updatedTransaction)
                                .eq("id", value: transaction.id)
                                .execute()

                            print(res)

                            await supabase.refreshTransactions()
                        } catch {
                            print("Erro ao atualizar transação #\(transaction.id, default: "n/a"): \(error)")
                        }
                    }

                    dismiss()
                }
            }
            .buttonStyle(.glassProminent)
        }
        .padding(16)
    }
}

#Preview {
    let transaction = Transaction(id: 123, name: "Test", amount_cents: 10000, payment_type: PaymentTypeDB(name: "Crédito"))
    TransactionDetailView(transaction: transaction)
}
