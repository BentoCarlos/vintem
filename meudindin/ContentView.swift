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

    private var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return supabase.transactionsDB
        } else {
            return supabase.transactionsDB.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var totalGasto: Double {
        supabase.transactionsDB.compactMap { $0.amount_cents }.reduce(0) { $0 + Double($1) } / 100.0
    }

    var body: some View {
        if supabase.loadingData {
            loadingView
        } else if supabase.errorLoadingData {
            errorView
        } else {
            mainView
        }
    }

    // ── Loading ──────────────────────────────────────────────────────
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Carregando transações...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await supabase.fetchTransactions()
        }
    }

    // ── Erro ─────────────────────────────────────────────────────────
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Erro ao carregar os dados")
                .font(.system(size: 16, weight: .semibold))

            Button("Tentar novamente") {
                Task { await supabase.fetchTransactions() }
            }
            .buttonStyle(.glassProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // ── Main ─────────────────────────────────────────────────────────
    private var mainView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Card de resumo total
                    summaryCard

                    // Gráfico
                    if !supabase.transactionsDB.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Por categoria", icon: "chart.pie.fill")

                            TransactionPieChartView()
                                .environmentObject(supabase)
                        }
                        .padding(16)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    }

                    // Lista de transações
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(
                            title: searchText.isEmpty ? "Todas as transações" : "Resultados",
                            icon: "list.bullet.rectangle",
                            badge: filteredTransactions.count
                        )

                        if filteredTransactions.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(filteredTransactions) { item in
                                    TransactionRowView(
                                        transaction: item,
                                        onDelete: { transactionToDelete in
                                            Task {
                                                await supabase.installments.deleteFromTransaction(for: transactionToDelete.id!)
                                                await supabase.transactions.delete(id: transactionToDelete.id!)
                                                await supabase.refreshTransactions()
                                            }
                                        }
                                    )
                                    .environmentObject(supabase)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12)) // ✅ corta o que vazar
                        }
                    }
                    .padding(16)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(20)
            }
            .searchable(text: $searchText, prompt: "Buscar transação...")
            .navigationTitle("Meu Dinheiro")
            .overlay(alignment: .bottomTrailing) {
                AddTransactionButton {
                    showAddTransactionSheet.toggle()
                }
                .padding(20)
            }
            .sheet(isPresented: $showAddTransactionSheet) {
                NewTransactionView()
                    .environmentObject(supabase)
            }
        }
    }

    // ── Card de resumo ────────────────────────────────────────────────
    private var summaryCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Total gasto")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(totalGasto, format: .currency(code: "BRL"))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("\(supabase.transactionsDB.count) transações")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Ícone decorativo
            Image(systemName: "brazilianrealsign.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint.opacity(0.3))
        }
        .padding(20)
        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
    }

    // ── Estado vazio ──────────────────────────────────────────────────
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text(searchText.isEmpty ? "Nenhuma transação ainda" : "Nenhum resultado para \"\(searchText)\"")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// ── Section Header ────────────────────────────────────────────────────
struct SectionHeader: View {
    let title: String
    let icon: String
    var badge: Int? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tint)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer()

            if let badge {
                Text("\(badge)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .glassEffect(in: Capsule())
            }
        }
    }
}

#Preview {
    ContentView()
}
