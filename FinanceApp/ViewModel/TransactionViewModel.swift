//
//  TransactionViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

final class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Int: Category] = [:]
    
    private let transactionsService: TransactionsServiceProtocol = TransactionsService()
    private let categoriesService: CategoriesServiceProtocol = CategoriesService()
    let direction: Direction
    
    var totalAmount: Decimal {
        transactions.map { $0.amount }.reduce(0, +)
    }
    
    init(direction: Direction) {
        self.direction = direction
        Task {
            await fetchInfo()
        }
    }
    
    func fetchInfo() async {
        do {
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
            let allTransactions = try await transactionsService.fetchTransactions(from: startOfDay, to: endOfDay)
            let categoriesArray = try await categoriesService.categories(direction: direction)
            self.categories = Dictionary(uniqueKeysWithValues: categoriesArray.map { ($0.id, $0) })
            
            self.transactions = allTransactions.filter { transaction in
                if let category = self.categories[transaction.categoryId] {
                    return category.direction == direction
                }
                return false
            }
            print(transactions)
            print(categories)
        } catch {
            print("error with fetching transactions")
        }
    }
}
