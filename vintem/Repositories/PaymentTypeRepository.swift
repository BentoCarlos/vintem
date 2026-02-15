//
//  PaymentTypeRepository.swift
//  meudindin
//
//  Created by Bento Carlos on 13/02/26.
//

import Supabase

struct PaymentTypeResult: Codable {
    let id: Int?
    let name: String
}

class PaymentTypeRepository {
    private var client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchPaymentType(for type: PaymentType) async throws -> Int? {
        do {
            let res: [PaymentTypeResult] = try await client
                .from("payment_types")
                .select("id, name")
                .eq("name", value: type.rawValue)
                .execute()
                .value

            return res.first?.id
        } catch {
            print("Erro ao tentar recuperar o tipo de pagamento: \(error)")
            return nil
        }
    }

    func insert(typeName: String) async throws -> Int? {
        do {
            let newType: PaymentTypeResult = PaymentTypeResult(id: nil, name: typeName)

            let res: [PaymentTypeResult] = try await client
                .from("payment_types")
                .insert(newType)
                .select()
                .execute()
                .value

            return res.first!.id
        } catch {
            print("Erro ao criar novo tipo de pagamento \(typeName): \(error)")
            return nil
        }
    }
}
