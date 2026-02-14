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
                    TransactionPieChartView()
                        .environmentObject(supabase)
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
                                .environmentObject(supabase)
                            }
                        }
                    }
                    //                .animation(.default, value: filteredTransactions)
                }
                .padding(20)
                .searchable(text: $searchText, prompt: "Buscar")
//                .background {
//                    Image("Background")
//                    .scaledToFill()
//                }
            }
            .navigationTitle("Minhas Transações")
            .overlay(alignment: .bottomTrailing) {
                AddTransactionButton {
                    showAddTransactionSheet.toggle()
                }
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

