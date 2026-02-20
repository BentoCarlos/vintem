//
//  InstallmentRepository.swift
//  meudindin
//
//  Created by Bento Carlos on 14/02/26.
//

import SwiftUI
import Supabase

struct Installment: Codable, Identifiable {
    let id: Int?
    let transaction_id: Int
    let portion: Int
    let total_portions: Int
    let payment_date: Date
    let created_at: Date
    let updated_at: Date
    let value: Int
}

class InstallmentRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchTransactionInstallments(for transactionId: Int) async throws -> [Installment] {
        return try await client
                .from("installments")
                .select()
                .eq("transaction_id", value: transactionId)
                .execute()
                .value
    }

    func insert(for id: Int, newInstallment: Installment) async {
        do {
            try await client
                .from("installments")
                .insert(newInstallment)
                .execute()
        } catch {
            print("Erro ao inserir parcela: \(error)")
        }
    }

    func deleteFromTransaction(for id: Int) async {
        do {
            try await client
                .from("installments")
                .delete()
                .eq("transaction_id", value: id)
                .execute()
        } catch {
            print("Erro ao remover parcela: \(error)")
        }
    }
}

