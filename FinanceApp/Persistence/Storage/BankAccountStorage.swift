//
//  BankAccountStorage.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

protocol BankAccountStorageProtocol {
    func getAccount() throws -> BankAccount?
    func update(_ account: BankAccount) throws
    func saveBackup(_ account: BankAccount, operationType: BackupOperationType) throws
    func fetchBackup() throws -> [BackupTransaction]
    func deleteBackup(id: Int) throws
}

final class BankAccountStorage: BankAccountStorageProtocol {
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
    }
    
    func getAccount() throws -> BankAccount? {
        let descriptor = FetchDescriptor<PersistentBankAccount>()
        return try modelContext.fetch(descriptor).first?.toBankAccount
    }
    
    func update(_ account: BankAccount) throws {
        let predicate = #Predicate<PersistentBankAccount> { $0.id == account.id }
        let descriptor = FetchDescriptor<PersistentBankAccount>(predicate: predicate)
        
        if let existingAccount = try modelContext.fetch(descriptor).first {
            existingAccount.name = account.name
            existingAccount.balance = account.balance
            existingAccount.currency = account.currency
            existingAccount.updatedAt = account.updatedAt
        } else {
            let persistentAccount = PersistentBankAccount(account: account)
            modelContext.insert(persistentAccount)
        }

        try modelContext.save()
    }

    func saveBackup(_ account: BankAccount, operationType: BackupOperationType) throws {
        let predicate = #Predicate<BackupTransaction> { $0.id == account.id }
        let descriptor = FetchDescriptor<BackupTransaction>(predicate: predicate)
        let existing = try modelContext.fetch(descriptor)
        existing.forEach { modelContext.delete($0) }

        let backup = BackupTransaction(
            id: account.id,
            operationType: operationType,
            transaction: Transaction(
                id: account.id,
                accountId: account.id,
                categoryId: 0,
                amount: account.balance,
                transactionDate: account.updatedAt,
                createdAt: account.createdAt,
                updatedAt: account.updatedAt
            )
        )
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
}
