//
//  TransactionViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Int: Category] = [:]
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var sortOption: SortOption = .date {
        didSet {
            sortTransactions()
        }
    }
    @Published var totalAmount: Decimal = 0
    @Published var currency: String = CurrencyTypes.rub.symbol
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    let direction: Direction
    let customDates: Bool
    
    private let transactionsService: TransactionsServiceProtocol = TransactionsService.shared
    private let categoriesService: CategoriesServiceProtocol = CategoriesService.shared
    private let bankAccountService: BankAccountsServiceProtocol = BankAccountsService.shared
    
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
        isLoading = true
        defer { isLoading = false }
        
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
            self.totalAmount = self.transactions.map { $0.amount }.reduce(0, +)
            
             let bankAccount = try await bankAccountService.getBankAccount()
            self.currency =  bankAccount?.currency ?? "$"
            
            sortTransactions()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка при загрузке транзакций"
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
