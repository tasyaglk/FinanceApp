//
//  TransactionStorage.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

protocol TransactionStorageProtocol {
    func fetchAll() throws -> [Transaction]
    func update(_ transaction: Transaction) throws
    func delete(id: Int) throws
    func create(_ transaction: Transaction) throws
    func saveBackup(_ transaction: Transaction, operationType: BackupOperationType) throws
    func fetchBackup() throws -> [BackupTransaction]
    func deleteBackup(id: Int) throws
    func exists(id: Int) throws -> Bool
}

final class TransactionStorage: TransactionStorageProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([PersistentTransaction.self, BackupTransaction.self, PersistentBankAccount.self, PersistentCategory.self])
        self.modelContainer = try ModelContainer(for: schema)
        self.modelContext = ModelContext(modelContainer)
    }
    
    func fetchAll() throws -> [Transaction] {
        let descriptor = FetchDescriptor<PersistentTransaction>()
        let persistentTransactions = try modelContext.fetch(descriptor)
        return persistentTransactions.map { $0.toTransaction }
    }
    
    func update(_ transaction: Transaction) throws {
        let predicate = #Predicate<PersistentTransaction> { $0.id == transaction.id }
        let descriptor = FetchDescriptor<PersistentTransaction>(predicate: predicate)
        guard let existingTransaction = try modelContext.fetch(descriptor).first else {
            throw TransactionsServiceError.transactionNotFound(id: transaction.id)
        }
        
        existingTransaction.accountId = transaction.accountId
        existingTransaction.categoryId = transaction.categoryId
        existingTransaction.amount = transaction.amount
        existingTransaction.transactionDate = transaction.transactionDate
        existingTransaction.comment = transaction.comment
        existingTransaction.createdAt = transaction.createdAt
        existingTransaction.updatedAt = transaction.updatedAt
        
        try modelContext.save()
    }
    
    func delete(id: Int) throws {
        let predicate = #Predicate<PersistentTransaction> { $0.id == id }
        let descriptor = FetchDescriptor<PersistentTransaction>(predicate: predicate)
        guard let transaction = try modelContext.fetch(descriptor).first else {
            throw TransactionsServiceError.transactionNotFound(id: id)
        }
        modelContext.delete(transaction)
        try modelContext.save()
    }
    
    func create(_ transaction: Transaction) throws {
        let persistentTransaction = PersistentTransaction(transaction: transaction)
        modelContext.insert(persistentTransaction)
        try modelContext.save()
    }
    
    func saveBackup(_ transaction: Transaction, operationType: BackupOperationType) throws {
        let backup = BackupTransaction(id: transaction.id, operationType: operationType, transaction: transaction)
        modelContext.insert(backup)
        try modelContext.save()
    }
    
    func fetchBackup() throws -> [BackupTransaction] {
        let descriptor = FetchDescriptor<BackupTransaction>()
        return try modelContext.fetch(descriptor)
    }
    
    func deleteBackup(id: Int) throws {
        let predicate = #Predicate<BackupTransaction> { $0.id == id }
        let descriptor = FetchDescriptor<BackupTransaction>(predicate: predicate)
        let backups = try modelContext.fetch(descriptor)
        backups.forEach { modelContext.delete($0) }
        try modelContext.save()
    }
    
    func exists(id: Int) throws -> Bool {
        let predicate = #Predicate<PersistentTransaction> { $0.id == id }
        let descriptor = FetchDescriptor<PersistentTransaction>(predicate: predicate)
        return try !modelContext.fetch(descriptor).isEmpty
    }
}
