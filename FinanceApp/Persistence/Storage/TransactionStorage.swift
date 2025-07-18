//
//  TransactionStorage.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

protocol TransactionStorageProtocol {
    func fetchTransactions() async throws -> [TransactionStorageModel]
    func createTransaction(_ transaction: TransactionStorageModel) async throws
    func updateTransaction(_ transaction: TransactionStorageModel) async throws
    func deleteTransaction(withId id: Int) async throws
}

@MainActor
final class TransactionStorage: TransactionStorageProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([TransactionStorageModel.self])
        modelContainer = try ModelContainer(for: schema, configurations: [])
        modelContext = modelContainer.mainContext
    }
    
    func fetchTransactions() async throws -> [TransactionStorageModel] {
        let descriptor = FetchDescriptor<TransactionStorageModel>()
        return try modelContext.fetch(descriptor)
    }
    
    func createTransaction(_ transaction: TransactionStorageModel) async throws {
        modelContext.insert(transaction)
        try modelContext.save()
    }
    
    func updateTransaction(_ transaction: TransactionStorageModel) async throws {
        modelContext.insert(transaction)
        try modelContext.save()
    }
    
    func deleteTransaction(withId id: Int) async throws {
        let descriptor = FetchDescriptor<TransactionStorageModel>(predicate: #Predicate { $0.id == id })
        if let transaction = try modelContext.fetch(descriptor).first {
            modelContext.delete(transaction)
            try modelContext.save()
        }
    }
}
