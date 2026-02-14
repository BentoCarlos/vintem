//
//  TransactionRepository.swift
//  meudindin
//
//  Created by Bento Carlos on 13/02/26.
//

import Foundation
import Supabase

class TransactionRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchAll() async throws -> [Transaction] {
        return try await client
            .from("transactions")
            .select("id, name, amount_cents, payment_type:payment_types(name)")
            .execute()
            .value
    }

    func insert(newTransaction: Transaction) async {
        do {
            try await client
                .from("transactions")
                .insert(newTransaction)
                .execute()
        }  catch {
            print("Erro ao inserir nova transação: \(error)")
        }
    }

    func update(for id : String, updatedTransaction: TransactionUpdate) async throws {
        do {
            let res = try await client
                .from("transactions")
                .update(updatedTransaction)
                .eq("id", value: id)
                .execute()
        } catch {
            print("Erro ao atualizar transação #\(id, default: "n/a"): \(error)")
        }
    }

    func delete(id: Int) async {
        do {
            try await client
                .from("transactions")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("Erro ao deletar transação: \(error)")
        }
    }
}
