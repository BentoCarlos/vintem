import SwiftUI
import SwiftData
import Supabase

struct NewTransactionView: View {
    @EnvironmentObject var supabase: SupabaseManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

//    @Query private var transactions: [Transaction]
//    @State private var transactions: [Transaction]

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
//        let nextId = (transactions.map { $0.id }.max() ?? 0) + 1
        let newTransaction = Transaction(
//            id: nextId,
            name: titulo,
//            value: valor ?? 0,
//            paymentType: tipoPagamento
        )

        // Adicionando uma animação leve na inserção
        withAnimation(.spring(duration: 0.4)) {
//            context.insert(newTransaction)
        }

        await insertTransaction(newTransaction: newTransaction)
        dismiss()
    }

    private func insertTransaction(newTransaction: Transaction) async {
        do {
            try await supabase.client
                .from("transactions")
                .insert(newTransaction)
                .execute()
        }  catch {
            print("Erro ao criar nova transação: \(error)")
        }
    }
}
