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
        switch tipoPagamento {
        case .credito:  return Color(red: 0.22, green: 0.55, blue: 1.0)
        case .debito:   return Color(red: 0.28, green: 0.78, blue: 0.58)
        case .pix:      return Color(red: 0.25, green: 0.72, blue: 0.65)
        case .dinheiro: return Color(red: 0.42, green: 0.75, blue: 0.35)
        case .outro:    return Color(red: 0.65, green: 0.55, blue: 0.85)
        }
    }

    private var paymentIcon: String {
        switch tipoPagamento {
        case .credito:  return "creditcard.fill"
        case .debito:   return "creditcard"
        case .pix:      return "qrcode"
        case .dinheiro: return "banknote.fill"
        case .outro:    return "ellipsis.circle.fill"
        }
    }

    var body: some View {
        ZStack {
            // Fundo gradiente animado
            LinearGradient(
                colors: [paymentColor.opacity(0.3), paymentColor.opacity(0.05), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: tipoPagamento)

            // Círculos decorativos
            Circle()
                .fill(paymentColor.opacity(0.12))
                .frame(width: 250)
                .blur(radius: 40)
                .offset(x: 130, y: -80)
                .animation(.easeInOut(duration: 0.5), value: tipoPagamento)

            VStack(spacing: 0) {

                // ── Header ───────────────────────────────────────────
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(paymentColor.opacity(0.15))
                            .frame(width: 56, height: 56)

                        Image(systemName: paymentIcon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(paymentColor)
                    }
                    .animation(.spring(response: 0.4), value: tipoPagamento)

                    Text("Nova Transação")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 28)
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -10)
                .animation(.spring(response: 0.5).delay(0.05), value: appeared)

                // ── Campos ───────────────────────────────────────────
                VStack(spacing: 14) {

                    // Valor em destaque
                    VStack(spacing: 6) {
                        Text("Valor")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)

                        TextField("R$ 0,00", value: $valor, format: .currency(code: "BRL"))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(valor != nil && valor! > 0 ? .primary : .tertiary)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 16))

                    // Nome
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Título", systemImage: "pencil")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.6)

                        TextField("Ex: Compra Mensal", text: $titulo)
                            .font(.system(size: 15, weight: .medium))
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                    }

                    // Tipo de pagamento
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Forma de Pagamento", systemImage: "creditcard")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.6)

                        HStack(spacing: 6) {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                PaymentTypeChip(
                                    type: type,
                                    isSelected: tipoPagamento == type,
                                    color: paymentColor
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        tipoPagamento = type
                                    }
                                }
                            }
                        }
                        .padding(6)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }

                    // Parcelas
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Parcelas", systemImage: "creditcard.and.numbers")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.6)

                        VStack(spacing: 8) {
                            var installmentValue: String {
                                var returnValue = ""

                                if let totalValue = valor {
                                    returnValue = String((totalValue / installments).formatted(.currency(code: Locale.current.currency?.identifier ?? "BRL")))
                                }

                                return returnValue
                            }

                            // Número de parcelas
                            Text("\(Int(installments))x \(installments == 1 ? "(À vista)" : installmentValue)")
                                .fontWeight(.bold)
                                .font(.title)
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                                .animation(.bouncy, value: installments)
                                .frame(maxWidth: .infinity, alignment: .center)

                            // Slider com botões
                            HStack(alignment: .center, spacing: 8) {
                                Button(action: {
                                    if installments > 1 { installments -= 1 }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(paymentColor)
                                        .padding(8)
                                }
                                .buttonStyle(.glass)

                                Slider(value: $installments, in: 1...24, step: 1)
                                    .tint(paymentColor)

                                Button(action: {
                                    if installments < 24 { installments += 1 }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(paymentColor)
                                        .padding(8)
                                }
                                .buttonStyle(.glass)
                            }

                            Divider()

                            // Vencimento
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vencimento")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                        .tracking(0.5)

                                    if installments > 1 {
                                        Text("1ª parcela")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(.tertiary)
                                    }
                                }

                                Spacer()

                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                        }
                        .padding(16)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }                }
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(response: 0.5).delay(0.1), value: appeared)

                Spacer()

                // ── Botões ───────────────────────────────────────────
                HStack(spacing: 12) {
                    Button("Cancelar") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.glassProminent)
                        .tint(.secondary)

                    Button(action: { Task { await saveTransaction() } }) {
                        HStack(spacing: 6) {
                            if isSaving {
                                ProgressView()
                                    .scaleEffect(0.75)
                                    .tint(.white)
                            } else {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            Text(isSaving ? "Salvando..." : "Adicionar")
                                .font(.system(size: 14, weight: .semibold))
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
                .animation(.spring(response: 0.5).delay(0.15), value: appeared)
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

            if (newTransactionId == nil) {
                throw TransactionError.newTransaction(message: "Erro ao recuperar o id da nova transação")
            }

            for i in 1...Int(installments) {
                var newInstallment: Installment {
                    return Installment(
                        id: nil,
                        transaction_id: newTransactionId!,
                        portion: i,
                        total_portions: Int(installments),
                        payment_date: Calendar.current.date(byAdding: .month, value: i - 1, to: selectedDate)!,
                        created_at: Date.now,
                        updated_at: Date.now
                    )
                }

                await supabase.installments.insert(for: newTransactionId!, newInstallment: newInstallment)
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
