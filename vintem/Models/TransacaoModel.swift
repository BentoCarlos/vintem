//
//  TransacaoModel.swift
//  meudindin
//
//  Created by Bento Carlos on 15/12/25.
//

import Foundation
import SwiftData

enum PaymentType: String, Codable, CaseIterable, Sendable {
    case dinheiro = "Dinheiro"
    case debito = "Débito"
    case credito = "Crédito"
    case pix = "Pix"
    case outro = "Outro"
}

struct PaymentTypeDB: Codable {
    let name: String

    var toEnum: PaymentType? {
        switch name {
        case "Crédito":  return .credito
        case "Débito":   return .debito
        case "Pix":      return .pix
        case "Dinheiro": return .dinheiro
        default:         return .outro
        }
    }
}

//@Model
final class Transaction: Identifiable, Codable {
    // Use UUID for SwiftData identity and mark it unique
    @Attribute(.unique) var id: Int? = nil
    var name: String
    var amount_cents: Int? = nil
    var payment_type: PaymentTypeDB? = nil
    var payment_type_id: Int? = nil
    var total_portions: Int? = nil
    var installment_value: Int? = nil
    var category_id: Int? = nil

    init(id: Int? = nil,
         name: String,
         amount_cents: Int? = nil,
         payment_type: PaymentTypeDB? = nil,
         payment_type_id: Int? = nil,
         total_installments: Int? = nil,
         installment_value: Int? = nil,
         category_id: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.amount_cents = amount_cents
        self.payment_type = payment_type
        self.payment_type_id = payment_type_id
        self.total_portions = total_installments
        self.installment_value = installment_value
        self.category_id = category_id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount_cents
        case payment_type
        case payment_type_id
        case total_portions
        case installment_value = "value"
        case category_id
    }
}
