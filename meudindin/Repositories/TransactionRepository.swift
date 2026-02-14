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
            .select("id, name, amount_cents")
            .execute()
            .value
    }
}
