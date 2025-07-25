//
//  BalanceChartView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 25.07.2025.
//

import SwiftUI
import Charts

struct BalanceChartView: View {
    @ObservedObject var viewModel: BalanceChartViewModel
    var isEditing: Bool

    var body: some View {
        if isEditing {
            EmptyView()
        } else {
            Chart(viewModel.dailyBalances) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Balance", abs(item.total))
                )
                .foregroundStyle(item.total >= 0 ? .green : .red)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 5)) { value in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 200)
            .padding()
        }
    }
}
