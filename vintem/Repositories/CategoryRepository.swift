//
//  CategoryRepository.swift
//  vintem
//
//  Created by Bento Carlos on 21/02/26.
//

import Supabase

struct Category: Codable, Identifiable, Equatable {
    let id: Int?
    let name: String
    let icon: String?
}

class CategoryRepository {
    private var client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchAll() async throws -> [Category] {
        return try await client
            .from("categories")
            .select()
            .execute()
            .value
    }

    func insert(newCategory: Category) async throws {
        do {
            try await client
                .from("categories")
                .insert(newCategory)
                .execute()
        } catch {
            print("Erro ao inserir categoria: \(error)")
        }
    }
}
