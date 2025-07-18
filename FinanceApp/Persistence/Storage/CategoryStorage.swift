//
//  CategoryStorage.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

protocol CategoryStorageProtocol {
    func fetchCategories() async throws -> [CategoryStorageModel]
    func updateCategories(_ categories: [CategoryStorageModel]) async throws
}

@MainActor
final class CategoryStorage: CategoryStorageProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([CategoryStorageModel.self])
        modelContainer = try ModelContainer(for: schema, configurations: [])
        modelContext = modelContainer.mainContext
    }
    
    func fetchCategories() async throws -> [CategoryStorageModel] {
        let descriptor = FetchDescriptor<CategoryStorageModel>()
        return try modelContext.fetch(descriptor)
    }
    
    func updateCategories(_ categories: [CategoryStorageModel]) async throws {
        let oldCategories = try await fetchCategories()
        for category in oldCategories {
            modelContext.delete(category)
        }
        for category in categories {
            modelContext.insert(category)
        }
        try modelContext.save()
    }
}
