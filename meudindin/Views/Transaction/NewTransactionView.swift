import SwiftUI
import SwiftData
import Supabase

enum TransactionError: Error {
    case newPaymentType(message: String)
}

struct NewTransactionView: View {
    @EnvironmentObject var supabase: SupabaseManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var titulo: String = ""
    @State private var valor: Double? = nil
    @State private var tipoPagamento: PaymentType = .credito

    var isFormInvalid: Bool {
        titulo.trimmingCharacters(in: .whitespaces).isEmpty || (valor ?? 0) <= 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Adicionar Transação")
                .font(.headline)

            // Usamos um formulário com estilo de coluna para dar espaço
            VStack(alignment: .leading, spacing: 12) {

                // Campo Título
                VStack(alignment: .leading, spacing: 4) {
                    Text("Título").font(.subheadline).foregroundColor(.secondary)
                    TextField("Ex: Compra Mensal", text: $titulo)
                        .textFieldStyle(.roundedBorder)
                }

                // Campo Valor
                VStack(alignment: .leading, spacing: 4) {
                    Text("Valor").font(.subheadline).foregroundColor(.secondary)
                    TextField("R$ 0,00", value: $valor, format: .currency(code: "BRL"))
                        .textFieldStyle(.roundedBorder)
                }

                // Campo Pagamento (O grande culpado pelo aperto)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Forma de Pagamento").font(.subheadline).foregroundColor(.secondary)

                    Picker("", selection: $tipoPagamento) {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.segmented) // Agora com espaço total para expandir
                    .labelsHidden()
                }
            }

            Spacer(minLength: 10)

            HStack {
                Button("Cancelar") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Salvar") { Task { await saveTransaction() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(isFormInvalid)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(25) // Aumentamos o padding interno da modal
        .frame(width: 420) // Aumentamos um pouco a largura para o segmented respirar
    }
    
    private func saveTransaction() async {
        do {
            var paymentId: Int? = nil

            paymentId = try? await supabase.paymentTypes.fetchPaymentType(for: tipoPagamento)

            if (paymentId == nil) {
                paymentId = try? await supabase.paymentTypes.insert(typeName: tipoPagamento.rawValue)
            }

            if (paymentId == nil) {
                throw TransactionError.newPaymentType(message: "Erro ao recuperar o tipo de pagamento. paymentId: \(paymentId, default: "n/a")")
            }

            let newTransaction = Transaction(
                name: titulo,
                amount_cents: valor != nil ? Int(valor! * 100) : 0,
                payment_type_id: paymentId
            )

            await supabase.transactions.insert(newTransaction: newTransaction)

            await supabase.refreshTransactions();

            dismiss()
        } catch {
            print("Erro ao criar nova transação: \(error)")
        }
    }
}

