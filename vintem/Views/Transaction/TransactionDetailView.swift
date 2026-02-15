//
//  TransactionDetailView.swift
//  meudindin
//

import SwiftUI
import Supabase

struct TransactionUpdate: Codable {
    let name: String
    let amount_cents: Int?
    let payment_type_id: Int?
}

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var supabase: SupabaseManager

    @State var transaction: Transaction
    @State var transactionName: String
    @State var transactionValue: Double?
    @State var transactionPaymentType: PaymentType

    @State private var isUpdating = false
    @State private var isLoading = true
    @State private var appeared = false
    @State private var installments: [Installment] = []
    @State private var scrollProxy: ScrollViewProxy? = nil

    init(transaction: Transaction) {
        _transaction = State(initialValue: transaction)
        _transactionName = State(initialValue: transaction.name)
        _transactionValue = State(initialValue: transaction.amount_cents.map { Double($0) / 100.0 })
        _transactionPaymentType = State(initialValue: transaction.payment_type?.toEnum ?? .outro)
    }

    private var transactionId: String {
        transaction.id.map { String($0) } ?? "—"
    }

    private var paymentColor: Color {
        switch transactionPaymentType {
        case .credito:  return Color(red: 0.22, green: 0.55, blue: 1.0)
        case .debito:   return Color(red: 0.28, green: 0.78, blue: 0.58)
        case .pix:      return Color(red: 0.25, green: 0.72, blue: 0.65)
        case .dinheiro: return Color(red: 0.42, green: 0.75, blue: 0.35)
        case .outro:    return Color(red: 0.65, green: 0.55, blue: 0.85)
        }
    }

    private var paymentIcon: String {
        switch transactionPaymentType {
        case .credito:  return "creditcard.fill"
        case .debito:   return "creditcard"
        case .pix:      return "qrcode"
        case .dinheiro: return "banknote.fill"
        case .outro:    return "ellipsis.circle.fill"
        }
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
            .animation(.easeInOut(duration: 0.4), value: transactionPaymentType)

            Circle()
                .fill(paymentColor.opacity(0.1))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: 150, y: -100)
                .animation(.easeInOut(duration: 0.4), value: transactionPaymentType)

            // ── Loading ──────────────────────────────────────────────
            if isLoading {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(paymentColor.opacity(0.15))
                            .frame(width: 64, height: 64)
                        ProgressView()
                            .scaleEffect(1.1)
                            .tint(paymentColor)
                    }
                    Text("Carregando transação...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity.animation(.easeOut(duration: 0.2)))

            } else {
                VStack(spacing: 0) {

                    ScrollView {
                        VStack(spacing: 0) {

                            // ── Header bold ───────────────────────────
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("TRANSAÇÃO")
                                        .font(.system(size: 11, weight: .heavy))
                                        .foregroundStyle(paymentColor)
                                        .tracking(3)
                                    Text("#\(transactionId)")
                                        .font(.system(size: 26, weight: .black, design: .monospaced))
                                        .foregroundStyle(.primary)
                                }

                                Spacer()

                                // Ícone animado
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
                                .animation(.spring(response: 0.35), value: transactionPaymentType)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 28)
                            .padding(.bottom, 20)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : -8)
                            .animation(.spring(response: 0.5).delay(0.05), value: appeared)

                            // ── Nome e Valor lado a lado ──────────────
                            HStack(spacing: 10) {
                                // Nome
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("NOME")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundStyle(paymentColor.opacity(0.8))
                                        .tracking(2)

                                    TextField("Nome da transação", text: $transactionName)
                                        .font(.system(size: 15, weight: .semibold))
                                        .textFieldStyle(.plain)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 14))

                                // Valor
                                VStack(alignment: .center, spacing: 6) {
                                    Text("VALOR")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundStyle(paymentColor.opacity(0.8))
                                        .tracking(2)

                                    TextField("0,00", value: $transactionValue, format: .currency(code: "BRL"))
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .textFieldStyle(.plain)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                            }
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)
                            .animation(.spring(response: 0.5).delay(0.08), value: appeared)

                            // ── Tipo de pagamento ─────────────────────
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PAGAMENTO")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(paymentColor.opacity(0.8))
                                    .tracking(2)
                                    .padding(.horizontal, 2)

                                HStack(spacing: 6) {
                                    ForEach(PaymentType.allCases, id: \.self) { type in
                                        PaymentTypeChip(
                                            type: type,
                                            isSelected: transactionPaymentType == type,
                                            color: paymentColor
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                transactionPaymentType = type
                                            }
                                        }
                                    }
                                }
                                .padding(6)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)
                            .animation(.spring(response: 0.5).delay(0.11), value: appeared)

                            // ── Parcelas ──────────────────────────────
                            if !installments.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("PARCELAS")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundStyle(paymentColor.opacity(0.8))
                                        .tracking(2)
                                        .padding(.horizontal, 2)

                                    ScrollViewReader { proxy in
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 8) {
                                                ForEach(installments) { installment in
                                                    let isCurrent = Calendar.current.isDate(
                                                        installment.payment_date,
                                                        equalTo: .now,
                                                        toGranularity: .month
                                                    )
                                                    let totalValue = Double(transaction.amount_cents ?? 0) / 100.0
                                                    let installmentValue = totalValue / Double(installment.total_portions)

                                                    InstallmentChip(
                                                        portion: installment.portion,
                                                        total: installment.total_portions,
                                                        value: installmentValue,
                                                        dueDate: installment.payment_date,
                                                        color: paymentColor,
                                                        isCurrentInstallment: isCurrent
                                                    )
                                                    .id(installment.id)
                                                }
                                            }
                                            .padding(.horizontal, 2)
                                            .padding(.vertical, 4)
                                        }
                                        .onAppear { scrollProxy = proxy }
                                    }
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)
                                .animation(.spring(response: 0.5).delay(0.14), value: appeared)
                            }

                            Spacer(minLength: 20)
                        }
                    }

                    // ── Botões ────────────────────────────────────────
                    HStack(spacing: 10) {
                        Button("Cancelar") { dismiss() }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.glassProminent)
                            .tint(.secondary)

                        Button(action: saveTransaction) {
                            HStack(spacing: 6) {
                                if isUpdating {
                                    ProgressView().scaleEffect(0.75).tint(.white)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                Text(isUpdating ? "Salvando..." : "Salvar")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.glassProminent)
                        .tint(paymentColor)
                        .disabled(isUpdating || transactionName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(20)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5).delay(0.18), value: appeared)
                }
                .transition(.opacity.animation(.easeIn(duration: 0.2)))
            }
        }
        .frame(width: 400)
        .onAppear {
            Task {
                installments = (try? await supabase.installments.fetchTransactionInstallments(for: transaction.id!)) ?? []

                withAnimation(.spring(response: 0.5)) {
                    isLoading = false
                }

                try? await Task.sleep(for: .milliseconds(50))

                withAnimation(.spring(response: 0.5)) {
                    appeared = true
                }

                try? await Task.sleep(for: .milliseconds(200))

                if let current = installments.first(where: {
                    Calendar.current.isDate($0.payment_date, equalTo: .now, toGranularity: .month)
                }) {
                    withAnimation(.spring(response: 0.6)) {
                        scrollProxy?.scrollTo(current.id, anchor: .center)
                    }
                }
            }
        }
    }

    private func saveTransaction() {
        Task {
            isUpdating = true
            do {
                let paymentTypeId = try await supabase.paymentTypes.fetchPaymentType(for: transactionPaymentType)
                let updated = TransactionUpdate(
                    name: transactionName,
                    amount_cents: transactionValue.map { Int($0 * 100) },
                    payment_type_id: paymentTypeId
                )
                try await supabase.transactions.update(for: transaction.id!, updatedTransaction: updated)
                await supabase.refreshTransactions()
                dismiss()
            } catch {
                print("Erro ao atualizar transação #\(transactionId): \(error)")
            }
            isUpdating = false
        }
    }
}

// ── PaymentTypeChip ───────────────────────────────────────────────────

struct PaymentTypeChip: View {
    let type: PaymentType
    let isSelected: Bool
    let color: Color

    private var icon: String {
        switch type {
        case .credito:  return "creditcard.fill"
        case .debito:   return "creditcard"
        case .pix:      return "qrcode"
        case .dinheiro: return "banknote"
        case .outro:    return "ellipsis.circle"
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? color : .secondary)

            Text(type.rawValue)
                .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? color : .secondary)
                .textCase(.uppercase)
                .tracking(0.3)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isSelected ? color.opacity(0.15) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// ── InstallmentChip ───────────────────────────────────────────────────

struct InstallmentChip: View {
    var portion: Int
    var total: Int
    var value: Double
    var dueDate: Date
    var color: Color
    var isCurrentInstallment: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("\(portion)")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(color)
                Text("/ \(total)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(color.opacity(0.5))
            }

            Divider()
                .overlay(color.opacity(0.2))

            Text(dueDate, style: .date)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(value, format: .currency(code: "BRL"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(12)
        .frame(minWidth: 100)
        .background(isCurrentInstallment ? color.opacity(0.25) : color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isCurrentInstallment ? color.opacity(0.6) : color.opacity(0.25),
                    lineWidth: isCurrentInstallment ? 2 : 1.5
                )
        )
    }
}

#Preview {
    let transaction = Transaction(
        id: 35,
        name: "Compra no Mercado",
        amount_cents: 24990,
        payment_type: PaymentTypeDB(name: "Crédito")
    )
    TransactionDetailView(transaction: transaction)
        .environmentObject(SupabaseManager())
}
