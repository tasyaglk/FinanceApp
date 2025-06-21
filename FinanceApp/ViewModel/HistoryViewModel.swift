//
//  HistoryViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 21.06.2025.
//

import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Int: Category] = [:]
    @Published var startDate: Date
    @Published var endDate: Date
    
    private let transactionsService: TransactionsServiceProtocol = TransactionsService()
    private let categoriesService: CategoriesServiceProtocol = CategoriesService()
    let direction: Direction
    
    var totalAmount: Decimal {
        transactions.map { $0.amount }.reduce(0, +)
    }
    
    init(direction: Direction) {
        self.direction = direction
        let calendar = Calendar.current
        self.endDate = Date()
        self.startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        Task {
            await fetchInfo()
        }
    }
    
    
    func fetchInfo() async {
        do {
            if endDate < startDate {
                endDate = startDate
            }
            
            if startDate > endDate {
                startDate = endDate
            }
            let allTransactions = try await transactionsService.fetchTransactions(from: startDate, to: endDate)
            let categoriesArray = try await categoriesService.categories(direction: direction)
            self.categories = Dictionary(uniqueKeysWithValues: categoriesArray.map { ($0.id, $0) })
            
            self.transactions = allTransactions.filter { transaction in
                if let category = self.categories[transaction.categoryId] {
                    return category.direction == direction
                }
                return false
            }
        } catch {
            print("error with fetching transactions")
        }
    }
}

