//
//  NewTransactionView.swift
//  meudindin
//

import SwiftUI
import SwiftData
import Supabase

enum TransactionError: Error {
    case newPaymentType(message: String)
    case newTransaction(message: String)
}

struct NewTransactionView: View {
    @EnvironmentObject var supabase: SupabaseManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var titulo: String = ""
    @State private var valor: Double? = nil
    @State private var tipoPagamento: PaymentType = .credito
    @State private var isSaving = false
    @State private var appeared = false
    @State private var installments: Double = 1
    @State private var selectedDate = Date()

    var isFormInvalid: Bool {
        titulo.trimmingCharacters(in: .whitespaces).isEmpty || (valor ?? 0) <= 0
    }

    private var paymentColor: Color {
        GetPaymentColor(type: tipoPagamento)
    }

    private var paymentIcon: String {
        GetPaymentIcon(type: tipoPagamento)
    }

    private var installmentValue: String {
        guard let totalValue = valor else { return "" }
        return (totalValue / installments).formatted(.currency(code: Locale.current.currency?.identifier ?? "BRL"))
    }

    var body: some View {
        ZStack {
            // Fundo
            LinearGradient(
                colors: [paymentColor.opacity(0.25), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: tipoPagamento)

            Circle()
                .fill(paymentColor.opacity(0.1))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: 150, y: -100)
                .animation(.easeInOut(duration: 0.4), value: tipoPagamento)

            VStack(spacing: 0) {

                // ── Header bold ───────────────────────────────────────
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NOVA")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(paymentColor)
                            .tracking(3)
                        Text("Transação")
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    // Ícone animado do tipo de pagamento
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(paymentColor.opacity(0.15))
                            .frame(width: 52, height: 52)
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(paymentColor.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 52, height: 52)
                        Image(systemName: paymentIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(paymentColor)
                    }
                    .animation(.spring(response: 0.35), value: tipoPagamento)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -8)
                .animation(.spring(response: 0.5).delay(0.05), value: appeared)

                // ── Dois campos lado a lado ───────────────────────────
                HStack(spacing: 10) {
                    // Título
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TÍTULO")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(paymentColor.opacity(0.8))
                            .tracking(2)

                        TextField("Ex: Mercado", text: $titulo)
                            .font(.system(size: 15, weight: .semibold))
                            .textFieldStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))

                    // Valor
                    ValueField(paymentColor: paymentColor, value: $valor)
                }
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(response: 0.5).delay(0.08), value: appeared)

                // ── Tipo de pagamento ─────────────────────────────────
                PaymentTypePicker(
                    paymentColor: paymentColor,
                    transactionPaymentType: $tipoPagamento,
                    appeared: $appeared
                )

                // ── Parcelas ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("PARCELAS")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(paymentColor.opacity(0.8))
                        .tracking(2)
                        .padding(.horizontal, 2)

                    VStack(spacing: 10) {
                        // Número + valor por parcela
                        HStack(alignment: .lastTextBaseline) {
                            HStack(alignment: .firstTextBaseline) {
                                TextField("", value: $installments, format: .number)
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(paymentColor)
                                    .contentTransition(.numericText())
                                    .animation(.bouncy, value: installments)
                                    .textFieldStyle(.plain)
                                    .fixedSize()

                                Text("x")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(paymentColor)
                                    .contentTransition(.numericText())
                                    .animation(.bouncy, value: installments)
                                    .textFieldStyle(.plain)
                            }

                            if installments == 1 || !installmentValue.isEmpty {
                                Text(installments == 1 ? "à vista" : "de \(installmentValue)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.interpolate)
                                    .animation(.bouncy, value: installments)
                            }
                            
                            Spacer()

                            // Vencimento compacto
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(paymentColor)
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                        }

                        // Slider com botões
                        HStack(spacing: 8) {
                            Button(action: { if installments > 1 { installments -= 1 } }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(paymentColor)
                                    .padding(8)
                            }
                            .buttonStyle(.glass)

                            Slider(value: $installments, in: 1...24, step: 1)
                                .tint(paymentColor)

                            Button(action: { if installments < 24 { installments += 1 } }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(paymentColor)
                                    .padding(8)
                            }
                            .buttonStyle(.glass)
                        }
                    }
                    .padding(14)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(response: 0.5).delay(0.14), value: appeared)

                Spacer()

                // ── Botões ────────────────────────────────────────────
                HStack(spacing: 10) {
                    Button("Cancelar") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.glassProminent)
                        .tint(.secondary)

                    Button(action: { Task { await saveTransaction() } }) {
                        HStack(spacing: 6) {
                            if isSaving {
                                ProgressView().scaleEffect(0.75).tint(.white)
                            } else {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            Text(isSaving ? "Salvando..." : "Adicionar")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glassProminent)
                    .tint(paymentColor)
                    .disabled(isFormInvalid || isSaving)
                }
                .padding(20)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5).delay(0.18), value: appeared)
            }
        }
        .frame(width: 420)
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private func saveTransaction() async {
        isSaving = true
        do {
            var paymentId: Int? = try? await supabase.paymentTypes.fetchPaymentType(for: tipoPagamento)

            if paymentId == nil {
                paymentId = try? await supabase.paymentTypes.insert(typeName: tipoPagamento.rawValue)
            }

            guard let paymentId else {
                throw TransactionError.newPaymentType(message: "Erro ao recuperar o tipo de pagamento.")
            }

            let newTransaction = Transaction(
                name: titulo,
                amount_cents: valor != nil ? Int(valor! * 100) : 0,
                payment_type_id: paymentId
            )

            let newTransactionId: Int? = await supabase.transactions.insert(newTransaction: newTransaction)

            guard let newTransactionId else {
                throw TransactionError.newTransaction(message: "Erro ao recuperar o id da nova transação")
            }

            for i in 1...Int(installments) {
                let newInstallment = Installment(
                    id: nil,
                    transaction_id: newTransactionId,
                    portion: i,
                    total_portions: Int(installments),
                    payment_date: Calendar.current.date(byAdding: .month, value: i - 1, to: selectedDate)!,
                    created_at: Date.now,
                    updated_at: Date.now,
                    value: newTransaction.amount_cents! / Int(installments)
                )
                await supabase.installments.insert(for: newTransactionId, newInstallment: newInstallment)
            }

            await supabase.refreshTransactions()
            dismiss()
        } catch {
            print("Erro ao criar nova transação: \(error)")
        }
        isSaving = false
    }
}

#Preview {
    NewTransactionView()
        .environmentObject({
            let manager = SupabaseManager()
            return manager
        }())
}
