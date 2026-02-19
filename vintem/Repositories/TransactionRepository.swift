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
            .select("id, name, amount_cents, payment_type:payment_types(name), installments(total_portions)")
            .execute()
            .value
    }

    func fetchByDate(month: Int, year: Int) async throws -> [Transaction] {
        let res: [Transaction] = try await client
            .rpc("get_transactions_by_month", params: ["par_month": month, "par_year": year])
            .execute()
            .value

        return res
    }

    func insert(newTransaction: Transaction) async -> Int? {
        do {
            struct TransactionInsert: Codable {
                let id: Int
            }

            let res: [TransactionInsert] = try await client
                .from("transactions")
                .insert(newTransaction)
                .select("id")
                .execute()
                .value

            return res.first!.id
        }  catch {
            print("Erro ao inserir nova transação: \(error)")
            return nil
        }
    }

    func update(for id : Int, updatedTransaction: TransactionUpdate) async throws {
        do {
            try await client
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
