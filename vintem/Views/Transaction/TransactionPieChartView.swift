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
    var id: String { type.rawValue }
    var type: PaymentType
    var totalValue: Double
}

extension PaymentType {
    var chartColor: Color {
        switch self {
        case .credito:  return Color(red: 0.22, green: 0.55, blue: 1.0)
        case .debito:   return Color(red: 0.28, green: 0.78, blue: 0.58)
        case .pix:      return Color(red: 0.25, green: 0.72, blue: 0.65)
        case .dinheiro: return Color(red: 0.42, green: 0.75, blue: 0.35)
        case .outro:    return Color(red: 0.65, green: 0.55, blue: 0.85)
        }
    }
}

struct TransactionPieChartView: View {
    @State private var selectedAngle: Double?
    @State private var selectedSectorId: String?
    @EnvironmentObject var supabase: SupabaseManager

    private var validTransactions: [(PaymentType, Double)] {
        supabase.transactionsDB.compactMap { transaction -> (PaymentType, Double)? in
            guard let type = transaction.payment_type?.toEnum,
                  let cents = transaction.amount_cents else { return nil }
            return (type, Double(cents) / 100.0)
        }
    }

    private var groupedData: [PaymentType: [(PaymentType, Double)]] {
        Dictionary(grouping: validTransactions, by: { $0.0 })
    }

    private var chartData: [PaymentData] {
        groupedData.map { (key, value) in
            PaymentData(type: key, totalValue: value.reduce(0) { $0 + $1.1 })
        }.sorted { $0.type.rawValue < $1.type.rawValue }
    }

    var body: some View {
        Chart(chartData, id: \.id) { data in
            SectorMark(
                angle: .value("Tipo", data.totalValue),
                innerRadius: .ratio(0.6),
                outerRadius: selectedSectorId == data.id ? .ratio(0.9) : .ratio(0.8),
                angularInset: 1
            )
            .cornerRadius(4)
            .foregroundStyle(data.type.chartColor)
            .opacity(selectedSectorId == nil || selectedSectorId == data.id ? 1.0 : 0.5)
            .annotation(position: .overlay) {
                Text(data.totalValue, format: .currency(code: "BRL"))
                    .font(.headline)
            }
        }
        .chartAngleSelection(value: $selectedAngle)
        .contentShape(Circle(), eoFill: false)
        .chartLegend(.hidden)
        .chartLegend(alignment: .center)
        .frame(minWidth: 300, minHeight: 300)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedSectorId)
        .onChange(of: selectedAngle) { _, newAngle in
            guard let newAngle else {
                selectedSectorId = nil
                return
            }
            var cumulative = 0.0
            selectedSectorId = chartData.first { data in
                let start = cumulative
                cumulative += data.totalValue
                return newAngle >= start && newAngle < cumulative
            }?.id
        }

        HStack(spacing: 16) {
            ForEach(chartData) { data in
                HStack(spacing: 6) {
                    Circle()
                        .fill(data.type.chartColor)
                        .frame(width: 10, height: 10)

                    Text(data.type.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
