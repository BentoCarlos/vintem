//
//  PaymentButtonConfig.swift
//  meudindin
//
//  Created by Bento Carlos on 16/12/25.
//

import SwiftUI

struct PaymentButtonConfig {
    let text: String
    let color: Color
}

struct PaymentTypeView: View {
    let buttonType: PaymentType

    private var buttonConfig: PaymentButtonConfig {
        switch buttonType {
        case .credito:
            return PaymentButtonConfig(text: "Crédito", color: .green)
        case .debito:
            return PaymentButtonConfig(text: "Débito", color: .blue)
        case .dinheiro:
            return PaymentButtonConfig(text: "Dinheiro", color: .yellow)
        case .pix:
            return PaymentButtonConfig(text: "Pix", color: .purple)
        case .outro:
            return PaymentButtonConfig(text: "Outro", color: .gray)
        }
    }

    var body: some View {
        Text(buttonConfig.text)
            .padding(.leading, 8)
            .padding(.trailing, 8)
            .padding(.top, 2)
            .padding(.bottom, 2)
            .background(buttonConfig.color)
            .cornerRadius(8)
            .overlay {
                Text(buttonConfig.text)
                    .foregroundStyle(Color.black)
            }
    }
}
