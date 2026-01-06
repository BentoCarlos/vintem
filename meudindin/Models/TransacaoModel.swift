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

@Model
final class Transaction: Identifiable {
    // Use UUID for SwiftData identity and mark it unique
    @Attribute(.unique) var id: Int
    var name: String
    var value: Double
    var paymentType: PaymentType

    init(id: Int, name: String, value: Double, paymentType: PaymentType) {
        self.id = id
        self.name = name
        self.value = value
        self.paymentType = paymentType
    }
}
