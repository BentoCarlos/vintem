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
    @State private var appeared = false

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
            // Fundo com gradiente animado baseado no tipo de pagamento
            LinearGradient(
                colors: [
                    paymentColor.opacity(0.35),
                    paymentColor.opacity(0.1),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: transactionPaymentType)

            // Círculos decorativos de fundo
            Circle()
                .fill(paymentColor.opacity(0.15))
                .frame(width: 280)
                .blur(radius: 40)
                .offset(x: 120, y: -80)
                .animation(.easeInOut(duration: 0.5), value: transactionPaymentType)

            Circle()
                .fill(paymentColor.opacity(0.1))
                .frame(width: 200)
                .blur(radius: 30)
                .offset(x: -100, y: 100)
                .animation(.easeInOut(duration: 0.5), value: transactionPaymentType)

            VStack(spacing: 0) {

                // ── Header ──────────────────────────────────────────
                VStack(spacing: 20) {

                    // ID badge + tipo badge
                    HStack {
                        Text("Transação #\(transactionId)")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .glassEffect(in: Capsule())

                        Spacer()

                        HStack(spacing: 5) {
                            Image(systemName: paymentIcon)
                                .font(.system(size: 11, weight: .bold))
                            Text(transactionPaymentType.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .textCase(.uppercase)
                                .tracking(0.8)
                        }
                        .foregroundStyle(paymentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .glassEffect(in: Capsule())
                        .animation(.easeInOut(duration: 0.3), value: transactionPaymentType)
                    }

                    // Valor em destaque editável
                    VStack(spacing: 4) {
                        Text("Valor")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)

                        TextField(
                            "R$ 0,00",
                            value: $transactionValue,
                            format: .currency(code: "BRL")
                        )
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -16)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: appeared)

                // ── Campos de edição ─────────────────────────────────
                VStack(spacing: 12) {

                    // Nome
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Nome", systemImage: "pencil")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.6)

                        TextField("Nome da transação", text: $transactionName)
                            .font(.system(size: 15, weight: .medium))
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.5).delay(0.1), value: appeared)

                    // Tipo de pagamento
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Forma de Pagamento", systemImage: "creditcard")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.6)

                        HStack(spacing: 8) {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                PaymentTypeChip(
                                    type: type,
                                    isSelected: transactionPaymentType == type,
                                    color: paymentColor
                                )
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
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.5).delay(0.15), value: appeared)
                }
                .padding(.horizontal, 20)

                Spacer()

                // ── Botões ───────────────────────────────────────────
                HStack(spacing: 12) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glassProminent)
                    .tint(.secondary)

                    Button(action: saveTransaction) {
                        HStack(spacing: 6) {
                            if isUpdating {
                                ProgressView()
                                    .scaleEffect(0.75)
                                    .tint(.white)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            Text(isUpdating ? "Salvando..." : "Salvar")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glassProminent)
                    .tint(paymentColor)
                    .disabled(isUpdating || transactionName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(20)
            }
        }
        .frame(width: 400)
        .onAppear {
            withAnimation {
                appeared = true
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

// ── Chip de tipo de pagamento ─────────────────────────────────────────

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
        .background(
            isSelected
                ? color.opacity(0.15)
                : Color.clear
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
        .animation(.spring(response: 0.3), value: isSelected)
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
}
