//
//  ContentView.swift
//  meudindin
//
//  Created by Bento Carlos on 08/12/25.
//

import SwiftUI
import SwiftData
import Supabase

struct Transacao: Decodable, Identifiable {
    let id: Int
    let transaction_type_id: Int
    let payment_type_id: Int
    let name: String
}

struct ContentView: View {
    let dbClient = SupabaseClient(supabaseURL: URL(string: "")!, supabaseKey: "")


    @State var searchText: String = ""
    @State var addButtonHover: Bool = false
    @State var showAddTransactionSheet: Bool = false

    @State var transactionsDB: [Transacao] = []

//    try await dbClient
//        .from("transactions")
//        .select()
//        .execute()
//        .value

    @Query(sort: \Transaction.id) private var transactions: [Transaction]
    @Environment(\.modelContext) private var context

    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return transactions
        } else {
            return transactions.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                let groupedData = Dictionary(grouping: filteredTransactions) { $0.paymentType }
                            let chartData = groupedData.map { (key, value) in
                                PaymentData(type: key, totalValue: value.reduce(0) { $0 + $1.value })
                            }.sorted { $0.type.rawValue < $1.type.rawValue }

                TransactionPieChartView(chartData: chartData)
                    .padding(20)

                LazyVStack(spacing: 8){
                    ForEach(filteredTransactions) { transaction in
                        TransactionRowView(
                            transaction: transaction,
                            onDelete: { transactionToDelete in
                                withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                                    context.delete(transactionToDelete)
                                }
                            }
                        )
                    }
                    if !transactionsDB.isEmpty {
                        Text("Dados vindos do Supabase:")
                            .font(.headline)
                            .padding(.top)
                        ForEach(transactionsDB) { item in
                            Text("Supabase: \(item.name)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .animation(.default, value: filteredTransactions)
            }
            .padding(20)
            .searchable(text: $searchText, prompt: "Buscar")
            /*.background {
                Image("Background")
                    .scaledToFill()
            }*/
        }
        .navigationTitle("Minhas Transações")
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                showAddTransactionSheet.toggle()
            }) {
                Image(systemName: "plus")
                    .padding(10)
            }
            .onHover() { isHovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    addButtonHover = isHovering
                }
            }
            .background(addButtonHover ? Color.gray.opacity(0.1): Color.clear)
            .clipShape(Circle())
            .padding()
            .buttonStyle(.glass)
        }
        .sheet(isPresented: $showAddTransactionSheet) {
            NewTransactionView()
        }
        .task {
            await fetchTransactions()
        }
    }

    func fetchTransactions() async {
        do {
            let dados: [Transacao] = try await dbClient
                .from("transactions")
                .select()
                .execute()
                .value

            // Atualiza a UI na thread principal
            await MainActor.run {
                self.transactionsDB = dados
                print("Sucesso! Carregadas \(dados.count) transações do Supabase.")
            }
        } catch {
            print("Erro ao buscar no Supabase: \(error)")
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Transaction.self, inMemory: true)
}

