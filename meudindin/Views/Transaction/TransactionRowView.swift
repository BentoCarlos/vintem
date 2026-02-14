//
//  TransactionRowView.swift
//  meudindin
//

import SwiftUI

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
            if let value = transactionValue {
                Text(value, format: .currency(code: "BRL"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            } else {
                Text("N/A")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
            }

            // ── Botão deletar ───────────────────────────────────────
            if isHovered {
                Button {
                    onDelete(transaction)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isHoveredDel ? .red : .secondary)
                        .padding(8)
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
