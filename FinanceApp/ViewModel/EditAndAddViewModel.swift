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
    private let categoriesService: CategoriesServiceProtocol = CategoriesService.shared
    private let bankAccountService: BankAccountsServiceProtocol = BankAccountsService.shared
    
    @Published var seletedCategory: Category? = nil
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var description: String = ""
    @Published var categories: [Category] = []
    @Published var bankAccountInfo: BankAccount?
    @Published var selectedTransaction: Transaction?
    @Published var showValidationAlert = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
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
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        self.amount = formatter.string(from: transaction.amount as NSNumber) ?? transaction.amount.description
        
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
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.categories = try await categoriesService.categories(direction: direction)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка при загрузке категорий"
        }
    }
    
    func loadBankAccountInfo() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.bankAccountInfo = try await bankAccountService.getBankAccount()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка при загрузке счета"
        }
    }
    
    func saveTransaction() async {
        guard validateInputs() else { return }
        
        guard let category = seletedCategory,
              let account = bankAccountInfo,
              let amountDecimal = decimalAmount()
        else { return }
        
        isLoading = true
        defer { isLoading = false }
        
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
        
        do {
            if isEditing {
                try await transactionsService.updateTransaction(transaction)
            } else {
                try await transactionsService.createTransaction(transaction)
            }
            await loadBankAccountInfo()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка при сохранении транзакции"
        }
    }
    
    func deleteTransaction() async {
        guard let transaction = selectedTransaction else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await transactionsService.deleteTransaction(withId: transaction.id)
            await loadBankAccountInfo()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка при удалении транзакции"
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
    
    func decimalAmount() -> Decimal? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: amount) {
            return number.decimalValue
        }
        return nil
    }
    
    func validateInputs() -> Bool {
        guard seletedCategory != nil,
              decimalAmount() != nil,
              !amount.isEmpty else {
            showValidationAlert = true
            return false
        }
        return true
    }
}
