//
//  SupabaseManager.swift
//  meudindin
//
//  Created by Bento Carlos on 13/02/26.
//

import Supabase
import Foundation
internal import Combine

class SupabaseManager: ObservableObject {
    @Published var client = SupabaseClient(
        supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_DB_URL"]!)!,
        supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_DB_KEY"]!
    )
    @Published var transactionsDB: [Transaction] = []
    @Published var loadingData: Bool = true
    @Published var errorLoadingData: Bool = false

    lazy var transactions = TransactionRepository(client: client)

    func fetchTransactions() async {
        await MainActor.run { loadingData = true }

        do {
            let response: [Transaction] = try await transactions.fetchAll()
            await MainActor.run {
                transactionsDB = response
                loadingData = false
                errorLoadingData = false
            }
        } catch {
            print("Erro ao buscar as transações: \(error)")
            await MainActor.run {
                loadingData = false
                errorLoadingData = true
            }
        }
    }

    func refreshTransactions() async {
        do {
            let response: [Transaction] = try await transactions.fetchAll()
            await MainActor.run {
                transactionsDB = response
            }
        } catch {
            print("Erro ao buscar as transações: \(error)")
        }
    }
}
