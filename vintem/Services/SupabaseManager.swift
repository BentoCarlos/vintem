//
//  SupabaseManager.swift
//  meudindin
//
//  Created by Bento Carlos on 13/02/26.
//

import Supabase
import Foundation
import Combine
import SwiftUI

struct DueDate: Codable, Identifiable {
    let id = UUID()
    let dueMonth: Int
    let dueYear: Int

    enum CodingKeys: String, CodingKey {
        case dueMonth = "due_month"
        case dueYear = "due_year"
    }
}

@MainActor
class SupabaseManager: ObservableObject {
    @Published var client = SupabaseClient(
        supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_DB_URL_LOCAL"]!)!,
        supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_DB_KEY_LOCAL"]!,
        options: SupabaseClientOptions(
            db: .init(
                decoder: {
                    let decoder = JSONDecoder()
                    // ✅ aceita múltiplos formatos de data
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)

                        let formats = [
                            "yyyy-MM-dd",                       // 2026-02-14
                            "yyyy-MM-dd'T'HH:mm:ss",            // 2026-02-14T00:00:00
                            "yyyy-MM-dd'T'HH:mm:ssZ",           // 2026-02-14T00:00:00Z
                            "yyyy-MM-dd'T'HH:mm:ss.SS",         // 2026-02-14T21:06:55.58 (2 dígitos)
                            "yyyy-MM-dd'T'HH:mm:ss.SSS",        // 2026-02-14T21:06:55.580 (3 dígitos)
                            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",       // com timezone
                            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",     // microsegundos (6 dígitos)
                            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"     // microsegundos com timezone
                        ]
                        let formatter = DateFormatter()
                        for format in formats {
                            formatter.dateFormat = format
                            if let date = formatter.date(from: dateString) {
                                return date
                            }
                        }

                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Invalid date format: \(dateString)"
                        )
                    }
                    return decoder
                }()
            )
        )
    )
    @Published var transactionsDB: [Transaction] = []
    @Published var categoriesDB: [Category] = []
    @Published var loadingData: Bool = true
    @Published var errorLoadingData: Bool = false

    lazy var transactions = TransactionRepository(client: client)
    lazy var paymentTypes = PaymentTypeRepository(client: client)
    lazy var installments = InstallmentRepository(client: client)
    lazy var categories   = CategoryRepository(client: client)

    func fetchTransactions() async {
        loadingData = true

        do {
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentYear = Calendar.current.component(.year, from: Date())

            let transactionsResponse: [Transaction] = try await transactions.fetchByDate(month: currentMonth, year: currentYear)
            transactionsDB = transactionsResponse
            loadingData = false
            errorLoadingData = false
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
            // Você vai precisar passar esses valores ou armazenar no SupabaseManager
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentYear = Calendar.current.component(.year, from: Date())

            let response: [Transaction] = try await transactions.fetchByDate(month: currentMonth, year: currentYear)
            withAnimation(.spring(duration: 0.3)) {
                transactionsDB = response
            }
        } catch {
            print("Erro ao buscar as transações: \(error)")
        }
    }

    func filterTransactions(month: Int, year: Int) async {
        do {
            let response: [Transaction] = try await transactions.fetchByDate(month: month, year: year)
            withAnimation(.spring(duration: 0.3)) {
                transactionsDB = response
            }
        } catch {
            print("Erro ao buscar as transações: \(error)")
        }
    }

    func refreshCategories() async {
        do {
            categoriesDB = try await categories.fetchAll()
        } catch {
            print("Erro ao buscar as categorias: \(error)")
        }
    }
}
