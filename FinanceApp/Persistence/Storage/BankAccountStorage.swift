//
//  BankAccountStorage.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

protocol BankAccountStorageProtocol {
    func fetchAccount() async throws -> BankAccountStorageModel?
    func updateAccount(_ account: BankAccountStorageModel) async throws
}

@MainActor
final class BankAccountStorage: BankAccountStorageProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([BankAccountStorageModel.self])
        modelContainer = try ModelContainer(for: schema, configurations: [])
        modelContext = modelContainer.mainContext
    }
    
    func fetchAccount() async throws -> BankAccountStorageModel? {
        let descriptor = FetchDescriptor<BankAccountStorageModel>()
        return try modelContext.fetch(descriptor).first
    }
    
    func updateAccount(_ account: BankAccountStorageModel) async throws {
        modelContext.insert(account)
        try modelContext.save()
    }
}
