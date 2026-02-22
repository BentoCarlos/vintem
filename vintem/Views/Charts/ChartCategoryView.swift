//
//  ChartCategoryView.swift
//  vintem
//
//  Created by Bento Carlos on 21/02/26.
//

import Charts
import SwiftUI
import Combine

struct ChartData: Identifiable {
    let id: Int
    let category: Category
    let total: Decimal
}

struct ChartCategoryView: View {
    @EnvironmentObject var supabase: SupabaseManager
    @State private var selectedAngle: Double?
    @State private var selectedSectorId: Int?
    @State private var chartData: [ChartData] = []

    var body: some View {
        Chart(chartData, id: \.id) { data in
            createSectorMark(for: data)
        }
        .chartAngleSelection(value: $selectedAngle)
        .contentShape(Circle(), eoFill: false)
        .chartLegend(alignment: .leading)
        .frame(minWidth: 300, minHeight: 300)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedSectorId)
        .onAppear {
            calculateChartData()
        }
        .onChange(of: supabase.transactionsDB) {
            withAnimation {
                calculateChartData()
            }
        }
        .onChange(of: selectedAngle) { _, newAngle in
            updateSelection(newAngle: newAngle)
        }
    }

    private func createSectorMark(for data: ChartData) -> some ChartContent {
        let isSelected = selectedSectorId == data.id
        let radius: MarkDimension = isSelected ? .ratio(0.9) : .ratio(0.8)
        let opacity: Double = (selectedSectorId == nil || isSelected) ? 1.0 : 0.5

        return SectorMark(
            angle: .value(data.category.name, Double(truncating: data.total as NSDecimalNumber)),
            innerRadius: .ratio(0.6),
            outerRadius: radius,
            angularInset: 1
        )
        .cornerRadius(4)
        .foregroundStyle(by: .value(data.category.name, data.category.name))
        .opacity(opacity)
        .annotation(position: .overlay) {
            annotationView(for: data)
        }
    }

    private func annotationView(for data: ChartData) -> some View {
        let isSelected = selectedSectorId == data.id
        let opacity = isSelected ? 1 : 0.6

        return Text(data.total, format: .currency(code: "BRL"))
            .font(.headline)
            .opacity(opacity)
    }

    func calculateChartData() {
        let data: [(Category, Decimal)] = supabase.transactionsDB.compactMap { transaction -> (Category, Decimal)? in
            guard let cents = transaction.installment_value else { return nil }

            let categoryId = transaction.category_id ?? 0
            var category = supabase.categoriesDB.first(where: {
                $0.id == categoryId
            })

            if category == nil {
                category = Category(id: 0, name: "Unknown", icon: nil)
            }

            let decimalCents = Decimal(cents)
            let decimalValue = decimalCents / Decimal(100)

            return (category!, decimalValue)
        }

        let groupedData: [Category: [(Category, Decimal)]] = Dictionary(grouping: data, by: { $0.0 })

        chartData = groupedData.map { (key, value) in
            let totalValue = value.reduce(0) { $0 + $1.1 }

            return ChartData(id: key.id!, category: key, total: totalValue)
        }
    }

    func updateSelection(newAngle: Double?) {
        guard let newAngle else {
            selectedSectorId = nil
            return
        }
        var cumulative = 0.0
        selectedSectorId =
            chartData.first { data in
                let start = cumulative
                let dataValue = Double(
                    truncating: data.total as NSDecimalNumber
                )
                cumulative += dataValue
                return newAngle >= start && newAngle < cumulative
            }?.id
    }
}
