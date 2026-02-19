//
//  Payment.swift
//  vintem
//
//  Created by Bento Carlos on 17/02/26.
//

import SwiftUI

func GetPaymentIcon(type: PaymentType) -> String {
    switch type {
    case .credito:  return "creditcard.fill"
    case .debito:   return "creditcard"
    case .pix:      return "qrcode"
    case .dinheiro: return "banknote.fill"
    case .outro:    return "ellipsis.circle.fill"
    }
}

func GetPaymentColor(type: PaymentType) -> Color {
    switch type {
    case .credito:  return Color(red: 0.22, green: 0.55, blue: 1.0)
    case .debito:   return Color(red: 0.28, green: 0.78, blue: 0.58)
    case .pix:      return Color(red: 0.25, green: 0.72, blue: 0.65)
    case .dinheiro: return Color(red: 0.42, green: 0.75, blue: 0.35)
    case .outro:    return Color(red: 0.65, green: 0.55, blue: 0.85)
    }
}
