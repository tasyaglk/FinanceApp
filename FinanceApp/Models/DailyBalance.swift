//
//  DailyBalance.swift
//  FinanceApp
//
//  Created by Тася Галкина on 25.07.2025.
//

import Foundation

struct DailyBalance: Identifiable {
    let id = UUID()
    let date: Date
    let total: Decimal
}
