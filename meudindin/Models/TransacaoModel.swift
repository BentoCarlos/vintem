//
//  TransacaoModel.swift
//  meudindin
//
//  Created by Bento Carlos on 15/12/25.
//

import Foundation
import SwiftData

// Make PaymentType persistable by giving it a raw value and Codable conformance
enum PaymentType: String, Codable, CaseIterable, Sendable {
    case dinheiro
    case debito
    case credito
    case pix
    case outro
}

//@Model
final class Transaction: Identifiable, Codable {
    // Use UUID for SwiftData identity and mark it unique
    @Attribute(.unique) var id: Int? = nil
    var name: String
    var amount_cents: Int? = nil
    var payment_type: PaymentType? = nil

    init(id: Int? = nil, name: String, amount_cents: Int? = nil, payment_type: PaymentType? = nil) {
        self.id = id
        self.name = name
        self.amount_cents = amount_cents
        self.payment_type = payment_type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount_cents
    }
}
