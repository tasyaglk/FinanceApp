//
//  TransactionViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

enum TransactionSortOption: String, CaseIterable, Identifiable {
    case date = "по дате"
    case amount = "по сумме транзакций"
    
    var id: String { rawValue }
}

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Int: Category] = [:]
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var sortOption: TransactionSortOption = .date {
        didSet {
            sortTransactions()
        }
    }
    
    let direction: Direction
    let customDates: Bool
    
    private let transactionsService: TransactionsServiceProtocol = TransactionsService()
    private let categoriesService: CategoriesServiceProtocol = CategoriesService()
    
    var totalAmount: Decimal {
        transactions.map { $0.amount }.reduce(0, +)
    }
    
    init(direction: Direction, customDates: Bool = false) {
        self.direction = direction
        self.customDates = customDates
        
        let calendar = Calendar.current
        let now = Date()
        
        if customDates {
            self.endDate = now
            self.startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? Date()
        } else {
            self.startDate = calendar.startOfDay(for: now)
            self.endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? Date()
        }
        
        Task {
            await fetchInfo()
        }
    }
    
    func fetchInfo() async {
        do {
            let from = Calendar.current.startOfDay(for: startDate)
            let to = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
            
            let allTransactions = try await transactionsService.fetchTransactions(from: from, to: to)
            let categoriesArray = try await categoriesService.categories(direction: direction)
            self.categories = Dictionary(uniqueKeysWithValues: categoriesArray.map { ($0.id, $0) })
            
            self.transactions = allTransactions.filter { transaction in
                if let category = self.categories[transaction.categoryId] {
                    return category.direction == direction
                }
                return false
            }
            
            sortTransactions()
        } catch {
            print("error with fetching transactions")
        }
    }
    
    private func sortTransactions() {
        switch sortOption {
        case .date:
            transactions.sort(by: { $0.createdAt < $1.createdAt })
        case .amount:
            transactions.sort(by: { $0.amount < $1.amount })
        }
    }
}
