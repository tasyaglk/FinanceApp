//
//  BankAccountsService.swift
//  FinanceApp
//
//  Created by Тася Галкина on 13.06.2025.
//

import Foundation
import SwiftData

protocol BankAccountsServiceProtocol {
    func getBankAccount() async throws -> BankAccount?
    func updateBankAccount(_ account: BankAccount) async throws
    func saveBackup(_ account: BankAccount, operationType: BackupOperationType) throws
    func updateLocal(_ account: BankAccount) throws
}

final class BankAccountsService: BankAccountsServiceProtocol {
    static let shared = BankAccountsService()
    
    private let client: BankAccountsClientProtocol
    private let storage: BankAccountStorageProtocol
    
    private init() {
        let networkClient = NetworkClient()
        self.client = BankAccountsClient(networkClient: networkClient)
        do {
            let container = try ModelContainer(for: Schema([PersistentTransaction.self, BackupTransaction.self, PersistentBankAccount.self, PersistentCategory.self]))
            self.storage = BankAccountStorage(modelContainer: container)
        } catch {
            fatalError("Failed to initialize BankAccountStorage: \(error)")
        }
    }
    
    func getBankAccount() async throws -> BankAccount? {
        do {
            try await syncBackup()
        } catch {
            print("Failed to sync with backup: \(error)")
        }
        
        do {
            switch await client.getBankAccount() {
            case .success(let account):
                try? storage.update(account)
                return account
            case .failure:
                return try? storage.getAccount()
            }
        } catch {
            return try? storage.getAccount()
        }
    }
    
    func updateBankAccount(_ account: BankAccount) async throws {
        do {
            switch await client.updateBankAccount(account) {
            case .success:
                try storage.update(account)
                try storage.deleteBackup(id: account.id)
            case .failure(let error):
                try storage.saveBackup(account, operationType: .update)
                try storage.update(account)
                throw error
            }
        } catch {
            try storage.saveBackup(account, operationType: .update)
            try storage.update(account)
            throw error
        }
    }
    
    
    func saveBackup(_ account: BankAccount, operationType: BackupOperationType) throws {
        try storage.saveBackup(account, operationType: operationType)
    }
    
    private func syncBackup() async throws {
        let backups = try storage.fetchBackup()
        
        for backup in backups {
            let account = BankAccount(
                id: backup.transaction.id,
                userId: backup.transaction.accountId,
                name: "",
                balance: backup.transaction.amount,
                currency: "$",
                createdAt: backup.transaction.createdAt,
                updatedAt: backup.transaction.updatedAt
            )
            
            switch BackupOperationType(rawValue: backup.operationType) {
            case .update:
                do {
                    _ = try await client.updateBankAccount(account)
                    try storage.deleteBackup(id: account.id)
                } catch {
                    continue
                }
            case .create, .delete, .none:
                continue
            }
        }
    }
    
    func recalculateBalance(using transactions: [Transaction], categories: [Category], currentAccount: BankAccount?) async throws -> BankAccount {
        let newBalance = transactions.reduce(Decimal(0)) { partialResult, tx in
            guard let cat = categories.first(where: { $0.id == tx.categoryId }) else { return partialResult }
            return partialResult + (cat.isIncome ? tx.amount : -tx.amount)
        }
        
        let account = BankAccount(
            id: currentAccount?.id ?? UUID().hashValue,
            userId: currentAccount?.userId ?? 0,
            name: currentAccount?.name ?? "Default Account",
            balance: newBalance,
            currency: currentAccount?.currency ?? "$",
            createdAt: currentAccount?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        do {
            try await updateBankAccount(account)
        } catch {
        }
        
        return account
    }
    
    func updateLocal(_ account: BankAccount) throws {
        try storage.update(account)
    }
}
