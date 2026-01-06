//
//  ChartData.swift
//  meudindin
//
//  Created by Bento Carlos on 16/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct PaymentData: Identifiable {
    var id = UUID()
    var type: PaymentType
    var totalValue: Double
}

struct TransactionPieChartView: View {
    @Query private var transactions: [Transaction]
    // selectedAngle é o que muda rapidamente no hover
    @State private var selectedAngle: Double?

    let chartData: [PaymentData]

    private var selectedSector: PaymentData? {
        guard let selectedAngle = selectedAngle else { return nil }
        var currentCumulativeValue = 0.0
        return chartData.first { data in
            let startAngle = currentCumulativeValue
            currentCumulativeValue += data.totalValue
            let endAngle = currentCumulativeValue
            return selectedAngle >= startAngle && selectedAngle < endAngle
        }
    }

    var body: some View {
        Chart(chartData, id: \.id) { data in
            SectorMark(
                angle: .value("Tipo", data.totalValue),
                innerRadius: .ratio(0.6),
                outerRadius: selectedSector?.id == data.id ? .ratio(0.9) : .ratio(0.8),
                angularInset: 1
            )
            .cornerRadius(4)
            .foregroundStyle(by: .value("Tipo", data.type.rawValue))
            .opacity(selectedSector == nil || selectedSector?.id == data.id ? 1.0 : 0.5)
            .annotation(position: .overlay) {
                Text(data.totalValue, format: .currency(code:"BRL"))
                    .font(.headline)
            }
        }
        .chartAngleSelection(value: $selectedAngle)
        .contentShape(Circle(), eoFill: false)
        .chartLegend(alignment: .center)
        .frame(minWidth: 300, minHeight: 300)
        .drawingGroup()
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedAngle)
    }
}
