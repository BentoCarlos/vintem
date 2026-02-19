//
//  PaymentTypePicker.swift
//  vintem
//
//  Created by Bento Carlos on 17/02/26.
//

import SwiftUI

struct PaymentTypePicker: View {
    var paymentColor: Color
    @Binding var transactionPaymentType: PaymentType
    @Binding var appeared: Bool

    var body: some View {
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
    }
}

// ── PaymentTypeChip ───────────────────────────────────────────────────
struct PaymentTypeChip: View {
    let type: PaymentType
    let isSelected: Bool
    let color: Color

    private var icon: String {
        GetPaymentIcon(type: type)
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
