//
//  ChartCategoryView.swift
//  vintem
//
//  Created by Bento Carlos on 21/02/26.
//

import Charts
import Combine
import SwiftUI

struct ChartData: Identifiable, Equatable {
    let id: Int
    let category: Category
    let total: Decimal
}

struct ChartCategoryView: View {
    @EnvironmentObject var supabase: SupabaseManager
    @State private var hoveredBar: String? = nil
    @State private var chartData: [ChartData] = []

    var body: some View {
        Chart(chartData, id: \.id) { data in
            createBarMark(for: data)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXSelection(value: $hoveredBar)
        .chartYScale(domain: 0...(max((chartData.map { Double(truncating: $0.total as NSDecimalNumber) }.max() ?? 0.0), 1.0)))
        .chartLegend(alignment: .leading)
        .frame(minWidth: 300, minHeight: 300)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.6),
            value: hoveredBar
        )
        .onAppear {
            calculateChartData()
        }
        .onChange(of: supabase.transactionsDB) {
            withAnimation {
                calculateChartData()
            }
        }
    }

    private func createBarMark(for data: ChartData) -> some ChartContent {
        let isSelected = hoveredBar == data.category.name || hoveredBar == nil
        let opacity: Double = (isSelected) ? 1.0 : 0.5

        return BarMark(
            x: .value("Categoria", data.category.name),
            y: .value("Total gasto", Double(truncating: data.total as NSDecimalNumber))
        )
        .cornerRadius(4)
        .foregroundStyle(by: .value(data.category.name, data.category.name))
        .opacity(opacity)
        .annotation(position: .top, alignment: .center) {
            annotationView(for: data)
        }
    }

    private func annotationView(for data: ChartData) -> some View {
        let isSelected = hoveredBar == data.category.name || hoveredBar == nil
        let opacity = isSelected ? 1 : 0.6

        return Text(data.total, format: .currency(code: "BRL"))
            .font(.headline)
            .opacity(opacity)
    }

    func calculateChartData() {
        let data: [(Category, Decimal)] = supabase.transactionsDB.compactMap {
            transaction -> (Category, Decimal)? in
            guard let cents = transaction.installment_value else { return nil }

            let categoryId = transaction.category_id ?? 0
            var category = supabase.categoriesDB.first(where: {
                $0.id == categoryId
            })

            if category == nil {
                category = Category(id: 0, name: "Unknown", icon: nil)
            }

            let decimalCents = Decimal(cents)
            let value = decimalCents / 100

            return (category!, value)
        }

        let groupedData: [Category: [(Category, Decimal)]] = Dictionary(
            grouping: data,
            by: { $0.0 }
        )

        chartData = groupedData.map { (key, value) in
            let totalValue = value.reduce(Decimal(0)) { $0 + $1.1 }

            return ChartData(id: key.id!, category: key, total: totalValue)
        }.sorted(by: { $0.total < $1.total})
    }
}
