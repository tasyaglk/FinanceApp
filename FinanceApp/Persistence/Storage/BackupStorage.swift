//
//  BackupStorage.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

protocol BackupStorageProtocol {
    func fetchBackupTransactions() async throws -> [BackupTransactionModel]
    func addBackupTransaction(_ transaction: TransactionStorageModel, action: String) async throws
    func deleteBackupTransaction(id: Int) async throws
}

@MainActor
final class BackupStorage: BackupStorageProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([BackupTransactionModel.self])
        modelContainer = try ModelContainer(for: schema, configurations: [])
        modelContext = modelContainer.mainContext
    }
    
    func fetchBackupTransactions() async throws -> [BackupTransactionModel] {
        let descriptor = FetchDescriptor<BackupTransactionModel>()
        return try modelContext.fetch(descriptor)
    }
    
    func addBackupTransaction(_ transaction: TransactionStorageModel, action: String) async throws {
        let backup = BackupTransactionModel(id: transaction.id, transaction: transaction, action: action)
        modelContext.insert(backup)
        try modelContext.save()
    }
    
    func deleteBackupTransaction(id: Int) async throws {
        let descriptor = FetchDescriptor<BackupTransactionModel>(predicate: #Predicate { $0.id == id })
        if let backup = try modelContext.fetch(descriptor).first {
            modelContext.delete(backup)
            try modelContext.save()
        }
    }
}
