//
//  BalanceChartViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 25.07.2025.
//

import Foundation

@MainActor
final class BalanceChartViewModel: ObservableObject {
    @Published var dailyBalances: [DailyBalance] = []
    
    private let transactionsService: TransactionsServiceProtocol
    
    init(transactionsService: TransactionsServiceProtocol = TransactionsService.shared) {
        self.transactionsService = transactionsService
    }
    
    func loadData() async {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        
        do {
            let transactions = try await transactionsService.fetchTransactions(from: startDate, to: endDate)
            let categories = try await CategoriesService.shared.categories()
            
            var grouped: [Date: Decimal] = [:]
            
            for tx in transactions {
                let day = calendar.startOfDay(for: tx.transactionDate)
                guard let category = categories.first(where: { $0.id == tx.categoryId }) else { continue }
                let signedAmount = category.isIncome ? tx.amount : -tx.amount
                grouped[day, default: 0] += signedAmount
            }
            
            var balances: [DailyBalance] = []
            
            for offset in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: offset, to: startDate) {
                    let total = grouped[calendar.startOfDay(for: date)] ?? 0
                    balances.append(DailyBalance(date: date, total: total))
                }
            }
            
            self.dailyBalances = balances
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
}
