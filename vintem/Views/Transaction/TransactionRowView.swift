//
//  TransactionRowView.swift
//  meudindin
//

import SwiftUI
import Supabase

struct TransactionRowView: View {
    let transaction: Transaction

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var supabase: SupabaseManager

    @State private var isHovered = false
    @State private var isHoveredDel = false
    @State private var isShowingDetail = false

    var onDelete: (Transaction) -> Void

    private var transactionId: String {
        transaction.id.map { String($0) } ?? "—"
    }

    private var transactionValue: Double? {
        transaction.amount_cents.map { Double($0) / 100.0 }
    }

    private var installmentValue: Double? {
        transaction.installment_value.map { Double($0) / 100.0 }
    }

    private var paymentType: PaymentType? {
        transaction.payment_type?.toEnum
    }

    private var paymentColor: Color {
        switch paymentType {
        case .credito:  return Color(red: 0.22, green: 0.55, blue: 1.0)
        case .debito:   return Color(red: 0.28, green: 0.78, blue: 0.58)
        case .pix:      return Color(red: 0.25, green: 0.72, blue: 0.65)
        case .dinheiro: return Color(red: 0.42, green: 0.75, blue: 0.35)
        case .outro:    return Color(red: 0.65, green: 0.55, blue: 0.85)
        case nil:       return .secondary
        }
    }

    private var paymentIcon: String {
        switch paymentType {
        case .credito:  return "creditcard.fill"
        case .debito:   return "creditcard"
        case .pix:      return "qrcode"
        case .dinheiro: return "banknote.fill"
        case .outro:    return "ellipsis.circle.fill"
        case nil:       return "questionmark.circle"
        }
    }

    var body: some View {
        HStack(spacing: 12) {

            // ── Ícone do tipo de pagamento ──────────────────────────
            ZStack {
                Circle()
                    .fill(paymentColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: paymentIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(paymentColor)
            }

            // ── Nome e ID ───────────────────────────────────────────
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("#\(transactionId)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // ── Valor ───────────────────────────────────────────────

            if let value = installmentValue {
                VStack(alignment: .leading) {
                    Text("Parcela:")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    Text(value, format: .currency(code: "BRL"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            } else {
                Text("N/A")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
            }

            Divider()

            if let value = transactionValue {
                VStack(alignment: .leading) {
                    Text("Valor Total:")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    Text(value, format: .currency(code: "BRL"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            } else {
                Text("N/A")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
            }

            // ── Categoria ───────────────────────────────────────────
            CategoryRowChip(
                transaction: transaction,
                color: paymentColor
            )

            // ── Botão deletar ───────────────────────────────────────
            if isHovered {
                Button {
                    onDelete(transaction)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isHoveredDel ? .red : .secondary)
                        .padding(8)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect()
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isHoveredDel = hovering
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .animation(.smooth(duration: 0.15), value: isHovered)
        .onHover { hovering in isHovered = hovering }
        .onTapGesture { isShowingDetail = true }
        .sheet(isPresented: $isShowingDetail) {
            TransactionDetailView(transaction: transaction)
                .environmentObject(supabase)
        }
    }
}

struct CategoryRowChip: View {
    @EnvironmentObject var supabase: SupabaseManager
    var transaction: Transaction
    var color: Color

    var category: Category? {
        supabase.categoriesDB.first { $0.id == transaction.category_id }
    }

    var body: some View {
        Text(category?.name ?? "Sem categoria")
            .foregroundStyle(color, .primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    VStack(spacing: 8) {
        // Preview com diferentes tipos de pagamento
        TransactionRowView(
            transaction: Transaction(
                id: 1,
                name: "Mercado Extra",
                amount_cents: 15790,
                payment_type: PaymentTypeDB(name: "Crédito"),
                payment_type_id: 1,
                total_installments: 1,
                installment_value: 15790,
                category_id: 1
            ),
            onDelete: { _ in print("Deletado") }
        )

        TransactionRowView(
            transaction: Transaction(
                id: 2,
                name: "Netflix Assinatura",
                amount_cents: 5990,
                payment_type: PaymentTypeDB(name: "Débito"),
                payment_type_id: 2,
                total_installments: 1,
                installment_value: 5990,
                category_id: 2
            ),
            onDelete: { _ in print("Deletado") }
        )

        TransactionRowView(
            transaction: Transaction(
                id: 3,
                name: "Restaurante",
                amount_cents: 8500,
                payment_type: PaymentTypeDB(name: "Pix"),
                payment_type_id: 3,
                total_installments: 1,
                installment_value: 8500,
                category_id: 3
            ),
            onDelete: { _ in print("Deletado") }
        )

        TransactionRowView(
            transaction: Transaction(
                id: 4,
                name: "Padaria",
                amount_cents: 1250,
                payment_type: PaymentTypeDB(name: "Dinheiro"),
                payment_type_id: 4,
                total_installments: 1,
                installment_value: 1250,
                category_id: 4
            ),
            onDelete: { _ in print("Deletado") }
        )

        TransactionRowView(
            transaction: Transaction(
                id: 5,
                name: "Compra Parcelada",
                amount_cents: 120000,
                payment_type: PaymentTypeDB(name: "Crédito"),
                payment_type_id: 1,
                total_installments: 12,
                installment_value: 10000,
                category_id: 5
            ),
            onDelete: { _ in print("Deletado") }
        )

        // Preview sem valor (nil)
        TransactionRowView(
            transaction: Transaction(
                id: 6,
                name: "Transação sem valor",
                amount_cents: nil,
                payment_type: PaymentTypeDB(name: "Outro"),
                payment_type_id: 5,
                total_installments: 1,
                installment_value: nil,
                category_id: nil
            ),
            onDelete: { _ in print("Deletado") }
        )
    }
    .padding()
    .frame(width: 600)
    .environmentObject(SupabaseManager())
}

