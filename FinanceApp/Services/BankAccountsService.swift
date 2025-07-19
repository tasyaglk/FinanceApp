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
        try await syncBackup()
        
        do {
            switch await client.getBankAccount() {
            case .success(let account):
                    try storage.update(account)
                return account
            case .failure(let error):
                throw error
            }
        } catch {
            return try storage.getAccount()
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
                try await client.updateBankAccount(account)
                try storage.deleteBackup(id: account.id)
            case .create, .delete, .none:
                continue
            }
        }
    }
}
