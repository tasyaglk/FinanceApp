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
        
        do {
            switch await bankAccountsClient.getBankAccount() {
            case .success(let account):
                try await syncBackupTransactions()
                switch await client.fetchTransactions(accountId: account.id, from: startDate, to: endDate) {
                case .success(let networkTransactions):
                    let existing = try storage.fetchAll()
                    for tx in existing {
                        try? storage.delete(id: tx.id)
                    }
                    for transaction in networkTransactions {
                        try? storage.create(transaction)
                    }
                    transactions = networkTransactions
                    return transactions
                case .failure(let error):
                    throw error
                }
            case .failure:
                throw TransactionsServiceError.accountNotFound
            }
        } catch {
            let local = try storage.fetchAll()
            let backup = try storage.fetchBackup().map { $0.transaction }
            transactions = (local + backup).removingDuplicates(by: \.id)
            return transactions.filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw TransactionsServiceError.transactionExists(id: transaction.id)
        }
        
        var isOffline = false
        
        do {
            switch await client.createTransaction(transaction) {
            case .success:
                break
            case .failure:
                try storage.saveBackup(transaction, operationType: .create)
                isOffline = true
            }
        } catch {
            try storage.saveBackup(transaction, operationType: .create)
            isOffline = true
        }
        
        try storage.create(transaction)
        transactions.append(transaction)
        
        if isOffline {
            try await updateAccountBalance()
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionsServiceError.transactionNotFound(id: transaction.id)
        }
        
        var isOffline = false
        
        do {
            switch await client.updateTransaction(transaction) {
            case .success:
                try? storage.deleteBackup(id: transaction.id)
            case .failure:
                try storage.saveBackup(transaction, operationType: .update)
                isOffline = true
            }
        } catch {
            try storage.saveBackup(transaction, operationType: .update)
            isOffline = true
        }
        
        try storage.update(transaction)
        transactions[index] = transaction
        
        if isOffline {
            try await updateAccountBalance()
        }
    }
    
    func deleteTransaction(withId id: Int) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionsServiceError.transactionNotFound(id: id)
        }
        
        let transaction = transactions[index]
        var isOffline = false
        
        do {
            switch await client.deleteTransaction(withId: id) {
            case .success:
                try? storage.deleteBackup(id: id)
            case .failure:
                try storage.saveBackup(transaction, operationType: .delete)
                isOffline = true
            }
        } catch {
            try storage.saveBackup(transaction, operationType: .delete)
            isOffline = true
        }
        
        try storage.delete(id: id)
        transactions.remove(at: index)
        
        if isOffline {
            try await updateAccountBalance()
        }
    }
    
    func getId() -> Int {
        return (transactions.map { $0.id }.max() ?? 0) + 1
    }
    
    private func syncBackupTransactions() async throws {
        let backups = try storage.fetchBackup()
        for backup in backups {
            let transaction = backup.transaction
            guard let op = BackupOperationType(rawValue: backup.operationType) else { continue }
            do {
                switch op {
                case .create:
                    _ = await client.createTransaction(transaction)
                case .update:
                    _ = await client.updateTransaction(transaction)
                case .delete:
                    _ = await client.deleteTransaction(withId: transaction.id)
                }
                try storage.deleteBackup(id: transaction.id)
            } catch {
                print("failed to sync transaction \(transaction.id): \(error)")
                continue
            }
        }
    }

    
    private func updateAccountBalance() async throws {
        var account: BankAccount?
        do {
            account = try await bankAccountsClient.getBankAccount().get()
        } catch {
            account = try bankAccountStorage.getAccount()
        }
        
        guard var acc = account else {
            throw TransactionsServiceError.accountNotFound
        }
        
        let all = try storage.fetchAll()
        let categories = try await CategoriesService.shared.categories()
        
        let newBalance = all.reduce(Decimal(0)) { sum, tx in
            guard let cat = categories.first(where: { $0.id == tx.categoryId }) else { return sum }
            return acc.balance + (cat.isIncome ? tx.amount : -tx.amount)
        }
        
        let updatedAccount = BankAccount(
            id: acc.id,
            userId: acc.userId,
            name: acc.name,
            balance: newBalance,
            currency: acc.currency,
            createdAt: acc.createdAt,
            updatedAt: acc.updatedAt
        )
        
        try bankAccountStorage.update(updatedAccount)
        try await BankAccountsService.shared.updateBankAccount(updatedAccount)
    }
}

extension Array where Element: Identifiable {
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
