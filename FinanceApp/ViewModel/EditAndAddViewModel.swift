//
//  EditAndAddViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 12.07.2025.
//

import SwiftUI

@MainActor
final class EditAndAddViewModel: ObservableObject {
    
    let direction: Direction
    private let transactionsService: TransactionsServiceProtocol = TransactionsService.shared
    private let categoriesService: CategoriesServiceProtocol = CategoriesService()
    private let bankAccountService: BankAccountsServiceProtocol = BankAccountsService.shared
    
    @Published var seletedCategory: Category? = nil
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var description: String = ""
    @Published var categories: [Category] = []
    @Published var bankAccountInfo: BankAccount?
    @Published var selectedTransaction: Transaction?
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    var isEditing: Bool { selectedTransaction != nil }
    
    init(direction: Direction, transaction: Transaction? = nil) {
        self.direction = direction
        self.selectedTransaction = transaction
        
        Task {
            await fetchAllCategories()
            await loadBankAccountInfo()
            if let transaction = transaction {
                prefillFields(with: transaction)
            }
        }
    }
    
    private func prefillFields(with transaction: Transaction) {
        self.amount = transaction.amount.description
        self.date = transaction.transactionDate
        self.time = transaction.transactionDate
        self.description = transaction.comment ?? ""
        
        Task {
            if categories.isEmpty {
                await fetchAllCategories()
            }
            self.seletedCategory = categories.first(where: { $0.id == transaction.categoryId })
        }
    }
    
    func fetchAllCategories() async {
        do {
            self.categories = try await categoriesService.categories(direction: direction)
        } catch {
            print("Error fetching categories")
        }
    }
    
    func loadBankAccountInfo() async {
        do {
            self.bankAccountInfo = try await bankAccountService.getBankAccount()
        } catch {
            print("Error loading bank account")
        }
    }
    
    func saveExpense() async {
        guard let category = seletedCategory,
              let account = bankAccountInfo,
              let amountDecimal = decimalAmount()
        else { return }
        
        let transactionDateTime = combine(date: date, time: time)
        
        let transaction = Transaction(
            id: selectedTransaction?.id ?? transactionsService.getId(),
            accountId: account.id,
            categoryId: category.id,
            amount: amountDecimal,
            transactionDate: transactionDateTime,
            comment: description.isEmpty ? nil : description,
            createdAt: selectedTransaction?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        var newBalance = account.balance
        
        if direction == .outcome {
            newBalance -= amountDecimal
        } else {
            newBalance += amountDecimal
        }
        
        do {
            if isEditing {
                try await transactionsService.updateTransaction(transaction)
            } else {
                try await transactionsService.createTransaction(transaction)
            }
            
            let updatedAccount = BankAccount(
                id: account.id,
                userId: account.userId,
                name: account.name,
                balance: newBalance,
                currency: account.currency,
                createdAt: account.createdAt,
                updatedAt: Date()
            )
            try await bankAccountService.updateBankAccount(updatedAccount)
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
    
    func deleteExpense() async {
        guard let transaction = selectedTransaction else { return }
        do {
            try await transactionsService.deleteTransaction(withId: transaction.id)
        } catch {
            print("Error deleting transaction")
        }
    }
    
    private func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        return calendar.date(from: dateComponents) ?? date
    }
    
    func decimalAmount() -> Decimal? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: amount) {
            return number.decimalValue
        }
        return nil
    }
    
    func filterAmountInput(_ input: String) -> String {
        var result = ""
        var hasSeparator = false
        
        for char in input {
            if char.isWholeNumber {
                result.append(char)
            } else if String(char) == decimalSeparator && !hasSeparator {
                result.append(char)
                hasSeparator = true
            }
        }
        return result
    }
}
