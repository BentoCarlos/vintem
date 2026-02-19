//
//  ValueField.swift
//  vintem
//
//  Created by Bento Carlos on 17/02/26.
//

import SwiftUI

struct ValueField: View {
    var paymentColor: Color
    @Binding var value: Double?

    var body: some View{
        VStack(alignment: .center, spacing: 6) {
            Text("VALOR")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(paymentColor.opacity(0.8))
                .tracking(2)

            TextField("0,00", value: $value, format: .currency(code: "BRL"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(value != nil && value! > 0 ? .primary : .tertiary)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}
