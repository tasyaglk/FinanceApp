//
//  AnalysisViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import Foundation
import PieChart

@MainActor
final class AnalysisViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Int: Category] = [:]
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var sortOption: SortOption = .date {
        didSet {
            sortTransactions()
            onDataUpdate?()
        }
    }
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    let direction: Direction
    let customDates: Bool
    var onDataUpdate: (() -> Void)?
    
    private let transactionsService: TransactionsServiceProtocol = TransactionsService.shared
    private let categoriesService: CategoriesServiceProtocol = CategoriesService.shared
    
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
            
            sortTransactions()
            onDataUpdate?()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка при загрузке данных"
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
    
    func didChangeStartDate(to date: Date) -> Bool {
        startDate = date
        if endDate < date {
            endDate = date
            return true
        }
        return false
    }
    
    func didChangeEndDate(to date: Date) -> Bool {
        endDate = date
        if startDate > date {
            startDate = date
            return true
        }
        return false
    }
    
    func getPercentage(for transaction: Transaction) -> String {
        guard totalAmount != 0 else {
            return "0%"
        }
        let ratio = ((transaction.amount as NSDecimalNumber).doubleValue * 100) / (totalAmount as NSDecimalNumber).doubleValue
        return String(format: "%.2f%%", ratio)
    }
    
    func transactionToPieChartEntities() -> [Entity] {
        sortTransactions()
        let total = transactions.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        
        var entities: [Entity] = []
        
        let topFive = transactions.prefix(5)
        for transaction in topFive {
            let label = categories[transaction.categoryId]?.name ?? "?"
            let value = transaction.amount
            entities.append(Entity(value: value, label: label))
        }
        
        let others = transactions.dropFirst(5)
        let othersSum = others.reduce(Decimal(0)) { $0 + $1.amount }
        
        if othersSum > 0 {
            entities.append(Entity(value: othersSum, label: "Остальные"))
        }
        return entities
    }
}
