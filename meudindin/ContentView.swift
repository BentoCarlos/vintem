//
//  ContentView.swift
//  meudindin
//
//  Created by Bento Carlos on 08/12/25.
//

import SwiftUI
import SwiftData
import Supabase

struct ContentView: View {
    @EnvironmentObject var supabase: SupabaseManager

    @State var searchText: String = ""
    @State var addButtonHover: Bool = false
    @State var showAddTransactionSheet: Bool = false

    @Environment(\.modelContext) private var context

//    var filteredTransactions: [Transaction] {
//        if searchText.isEmpty {
//            return transactions
//        } else {
//            return transactions.filter {
//                $0.name.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }

    var body: some View {
        if supabase.loadingData {
            ProgressView()
                .task {
                    await supabase.fetchTransactions()
                }
        } else if supabase.errorLoadingData {
            Text("Erro ao carregar os dados")
        } else {
            NavigationStack {
                ScrollView {
                    // Filtra transações que têm payment_type e amount_cents válidos
                    let validTransactions = supabase.transactionsDB.compactMap { transaction -> (PaymentType, Double)? in
                        guard let type = transaction.payment_type?.toEnum,
                              let cents = transaction.amount_cents else { return nil }
                        return (type, Double(cents / 100))
                    }

                    // Agrupa e soma
                    let groupedData = Dictionary(grouping: validTransactions, by: { $0.0 })

                    let chartData = groupedData.map { (key, value) in
                        PaymentData(
                            type: key,
                            totalValue: value.reduce(0) { $0 + $1.1 }
                        )
                    }.sorted { $0.type.rawValue < $1.type.rawValue }
                    TransactionPieChartView(chartData: chartData)
                        .padding(20)

                    LazyVStack(spacing: 8){
                        //                    ForEach(filteredTransactions) { transaction in
                        //                        TransactionRowView(
                        //                            transaction: transaction,
                        //                            onDelete: { transactionToDelete in
                        //                                withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                        //                                    context.delete(transactionToDelete)
                        //                                }
                        //                            }
                        //                        )
                        //                    }
                        if !supabase.transactionsDB.isEmpty {
                            ForEach(supabase.transactionsDB) { item in
                                TransactionRowView(
                                    transaction: item,
                                    onDelete: { transactionToDelete in
                                        Task {
                                            await supabase.transactions.delete(id: transactionToDelete.id!)
                                            await supabase.refreshTransactions()
                                        }
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                            }
                        }
                    }
                    //                .animation(.default, value: filteredTransactions)
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
                    .environmentObject(supabase)
            }
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: Transaction.self, inMemory: true)
}

