//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Тася Галкина on 14.06.2025.
//

import Foundation
import SwiftData

enum TransactionsServiceError: Error, LocalizedError {
    case transactionExists(id: Int)
    case transactionNotFound(id: Int)
    case invalidTransaction
    case accountNotFound
    
    var errorDescription: String? {
        switch self {
        case .transactionExists(let id):
            return "Транзакция с ID \(id) уже существует"
        case .transactionNotFound(let id):
            return "Транзакция с ID \(id) не найдена"
        case .invalidTransaction:
            return "Неверные данные транзакции"
        case .accountNotFound:
            return "Счет не найден"
        }
    }
}

protocol TransactionsServiceProtocol {
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func createTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(withId id: Int) async throws
    func getId() -> Int
}

@MainActor
final class TransactionsService: TransactionsServiceProtocol {
    static let shared = TransactionsService()
    
    private let client: TransactionsClientProtocol
    private let bankAccountsClient: BankAccountsClientProtocol
    private let storage: TransactionStorageProtocol
    private let bankAccountStorage: BankAccountStorageProtocol
    private var transactions: [Transaction] = []
    
    private init() {
        let networkClient = NetworkClient()
        self.client = TransactionsClient(networkClient: networkClient)
        self.bankAccountsClient = BankAccountsClient(networkClient: networkClient)
        do {
            let container = try ModelContainer(for: Schema([PersistentTransaction.self, BackupTransaction.self, PersistentBankAccount.self, PersistentCategory.self]))
            self.storage = try TransactionStorage()
            self.bankAccountStorage = BankAccountStorage(modelContainer: container)
        } catch {
            fatalError("Failed to initialize storage: \(error)")
        }
    }
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        try await syncBackupTransactions()
        
        do {
            switch await bankAccountsClient.getBankAccount() {
            case .success(let account):
                switch await client.fetchTransactions(accountId: account.id, from: startDate, to: endDate) {
                case .success(let networkTransactions):
                    for transaction in networkTransactions {
                        try storage.create(transaction)
                    }
                    self.transactions = networkTransactions
                    let backups = try storage.fetchBackup()
                    for backup in backups {
                        try storage.deleteBackup(id: backup.id)
                    }
                    return networkTransactions.filter {
                        $0.transactionDate >= startDate && $0.transactionDate <= endDate
                    }
                case .failure(let error):
                    throw error
                }
            case .failure:
                throw TransactionsServiceError.accountNotFound
            }
        } catch {
            let localTransactions = try storage.fetchAll()
            let backupTransactions = try storage.fetchBackup().map { $0.transaction }
            let allTransactions = (localTransactions + backupTransactions).removingDuplicates(by: \.id)
            self.transactions = allTransactions
            return allTransactions.filter {
                $0.transactionDate >= startDate && $0.transactionDate <= endDate
            }
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        if transactions.contains(where: { $0.id == transaction.id }) {
            throw TransactionsServiceError.transactionExists(id: transaction.id)
        }
        
        do {
            switch await client.createTransaction(transaction) {
            case .success:
                try storage.create(transaction)
                transactions.append(transaction)
                try await updateAccountBalance(transaction: transaction)
                try storage.deleteBackup(id: transaction.id)
            case .failure(let error):
                try storage.saveBackup(transaction, operationType: .create)
                try storage.create(transaction)
                transactions.append(transaction)
                try await updateAccountBalance(transaction: transaction)
                try await saveAccountBackup()
                throw error
            }
        } catch {
            try storage.saveBackup(transaction, operationType: .create)
            try storage.create(transaction)
            transactions.append(transaction)
            try await updateAccountBalance(transaction: transaction)
            try await saveAccountBackup()
            throw error
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionsServiceError.transactionNotFound(id: transaction.id)
        }
        
        do {
            switch await client.updateTransaction(transaction) {
            case .success:
                try storage.update(transaction)
                transactions[index] = transaction
                try await updateAccountBalance(transaction: transaction)
                try storage.deleteBackup(id: transaction.id)
            case .failure(let error):
                try storage.saveBackup(transaction, operationType: .update)
                try storage.update(transaction)
                transactions[index] = transaction
                try await updateAccountBalance(transaction: transaction) // Update balance in offline mode
                try await saveAccountBackup()
                throw error
            }
        } catch {
            try storage.saveBackup(transaction, operationType: .update)
            try storage.update(transaction)
            transactions[index] = transaction
            try await updateAccountBalance(transaction: transaction)
            try await saveAccountBackup()
            throw error
        }
    }
    
    func deleteTransaction(withId id: Int) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionsServiceError.transactionNotFound(id: id)
        }
        
        let transaction = transactions[index]
        
        do {
            switch await client.deleteTransaction(withId: id) {
            case .success:
                try storage.delete(id: id)
//                transactions.remove(at: index)
                try await updateAccountBalance(transaction: transaction)
                try storage.deleteBackup(id: id)
            case .failure(let error):
                try storage.saveBackup(transactions[index], operationType: .delete)
                try storage.delete(id: id)
                transactions.remove(at: index)
                try await updateAccountBalance(transaction: transaction)
                try await saveAccountBackup()
                throw error
            }
        } catch {
//            try storage.saveBackup(transactions[index], operationType: .delete)
            try storage.delete(id: id)
//            transactions.remove(at: index)
            try await updateAccountBalance()
            try await saveAccountBackup()
            throw error
        }
    }
    
    func getId() -> Int {
        return (transactions.map { $0.id }.max() ?? 0) + 1
    }
    
    private func syncBackupTransactions() async throws {
        let backups = try storage.fetchBackup()
        for backup in backups {
            let transaction = backup.transaction
            switch BackupOperationType(rawValue: backup.operationType) {
            case .create:
                try await client.createTransaction(transaction)
                try storage.deleteBackup(id: transaction.id)
            case .update:
                try await client.updateTransaction(transaction)
                try storage.deleteBackup(id: transaction.id)
            case .delete:
                try await client.deleteTransaction(withId: transaction.id)
                try storage.deleteBackup(id: transaction.id)
            case .none:
                continue
            }
        }
    }
    
    private func updateAccountBalance(transaction: Transaction? = nil) async throws {
        var account: BankAccount?
        do {
            account = try await bankAccountsClient.getBankAccount().get()
        } catch {
            account = try bankAccountStorage.getAccount()
        }
        
        guard let account = account else {
            throw TransactionsServiceError.accountNotFound
        }
        
        var updatedBalance = account.balance
        if let transaction = transaction {
            let categories = try await CategoriesService.shared.categories()
            guard let category = categories.first(where: { $0.id == transaction.categoryId }) else {
                throw TransactionsServiceError.invalidTransaction
            }
        } else {
            let transactions = try storage.fetchAll()
            let categories = try await CategoriesService.shared.categories()
            updatedBalance = transactions.reduce(Decimal(0)) { balance, transaction in
                guard let category = categories.first(where: { $0.id == transaction.categoryId }) else {
                    return balance
                }
                let ans =  balance + (category.isIncome ? transaction.amount : -transaction.amount)
                return ans
            }
        }
        
        let updatedAccount = BankAccount(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: updatedBalance,
            currency: account.currency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        try bankAccountStorage.update(updatedAccount)
        try await BankAccountsService.shared.updateBankAccount(updatedAccount)
    }
    
    private func saveAccountBackup() async throws {
        var account: BankAccount?
        do {
            account = try await bankAccountsClient.getBankAccount().get()
        } catch {
            account = try bankAccountStorage.getAccount()
        }
        
        guard let account = account else {
            throw TransactionsServiceError.accountNotFound
        }
        try await BankAccountsService.shared.saveBackup(account, operationType: .update)
    }
}

extension Array where Element: Identifiable {
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
