//
//  CategoryPicker.swift
//  vintem
//
//  Created by Bento Carlos on 20/02/26.
//

import SwiftUI

enum CategoryType: String, CaseIterable, Codable {
    case assinatura = "Assinatura"
    case livros = "Livros"
    case eletronicos = "Eletrônicos"
    case jogos = "Jogos"
    case comida = "Comida"
    case outros = "Outros"

    var icon: String {
        switch self {
        case .assinatura: return "arrow.triangle.2.circlepath"
        case .livros: return "book.fill"
        case .eletronicos: return "laptopcomputer"
        case .jogos: return "gamecontroller.fill"
        case .comida: return "fork.knife"
        case .outros: return "ellipsis.circle.fill"
        }
    }
}

struct CategoryPicker: View {
    @EnvironmentObject var supabase: SupabaseManager
    var paymentColor: Color
    @Binding var appeared: Bool
    @Binding var category: Category?
    var transaction: Transaction?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CATEGORIA")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(paymentColor.opacity(0.8))
                .tracking(2)
                .padding(.horizontal, 2)

            if supabase.categoriesDB.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundStyle(Color.gray)

                    Text("Nenhuma categoria ainda")
                        .foregroundStyle(Color.gray)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(supabase.categoriesDB, id: \.id) { cat in
                            CategoryChip(
                                category: cat,
                                isSelected: category?.id == cat.id,
                                color: paymentColor
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    category = cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.spring(response: 0.5).delay(0.11), value: appeared)
        .onAppear {
            // Set initial selection from existing transaction, if any and categories already loaded
            if let txn = transaction, let catID = txn.category_id {
                if let found = supabase.categoriesDB.first(where: { $0.id == catID }) {
                    category = found
                }
            }

            // Fetch categories if empty, then attempt to resolve selection again
            if supabase.categoriesDB.isEmpty {
                Task {
                    do {
                        supabase.categoriesDB = try await supabase.categories.fetchAll()
                        // After fetching, try to set the category again based on the transaction
                        if let txn = transaction, let catID = txn.category_id {
                            if let found = supabase.categoriesDB.first(where: { $0.id == catID }) {
                                category = found
                            }
                        }
                    } catch {
                        print("Erro ao recuperar as categorias: \(error)")
                    }
                }
            }
        }
    }
}

// ── Chip customizado ──────────────────────────────────────────
struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            if let iconName = category.icon {
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? color : .secondary)
            }

            Text(category.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? color.opacity(0.15) : Color.primary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isSelected ? color.opacity(0.4) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    NewTransactionView()
        .environmentObject({
            let manager = SupabaseManager()
            return manager
        }())
}
