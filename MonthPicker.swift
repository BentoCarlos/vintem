//
//  MonthPicker.swift
//  vintem
//
//  Created by Bento Carlos on 19/02/26.
//

import SwiftUI
import Supabase

struct MonthPicker: View {
    @Binding var month: Int
    @Binding var year: Int
    @EnvironmentObject var supabase: SupabaseManager

    var body: some View {
        HStack(spacing: 12) {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
                    .glassEffect(in: Circle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Text(Utils.MonthToString(monthNumber: month))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(minWidth: 85)
                    .animation(.spring(response: 0.5).delay(0.05), value: month)

                Text(String(year))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 55)
                    .animation(.spring(response: 0.5).delay(0.05), value: year)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .glassEffect(in: Capsule())

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
                    .glassEffect(in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    func previousMonth() {
        if month == 1 {
            month = 12
            year -= 1
        } else {
            month -= 1
        }

        Task {
            await supabase.filterTransactions(month: month, year: year)
        }
    }

    func nextMonth() {
        if month == 12 {
            month = 1
            year += 1
        } else {
            month += 1
        }

        Task {
            await supabase.filterTransactions(month: month, year: year)
        }
    }
}

#Preview {
    MonthPicker(month: .constant(1), year: .constant(2025))
}
