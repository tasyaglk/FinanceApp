//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Тася Галкина on 13.06.2025.
//

import Foundation
import SwiftData

protocol CategoriesServiceProtocol {
    func categories() async throws -> [Category]
    func categories(direction: Direction) async throws -> [Category]
}

@MainActor
final class CategoriesService: CategoriesServiceProtocol {
    static let shared = CategoriesService()
    
    private let client: CategoriesClientProtocol
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    private init() {
        self.client = CategoriesClient(networkClient: NetworkClient())
        do {
            let schema = Schema([PersistentTransaction.self, BackupTransaction.self, PersistentBankAccount.self, PersistentCategory.self])
            self.modelContainer = try ModelContainer(for: schema)
            self.modelContext = ModelContext(modelContainer)
            self.modelContext.autosaveEnabled = true
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
    
    func categories() async throws -> [Category] {
        do {
            let result = await client.categories()
            switch result {
            case .success(let categories):
                print("Received \(categories.count) categories from network")
                let uniqueCategories = categories.removingDuplicates(by: \.id)
                print("After deduplication, \(uniqueCategories.count) unique categories")
                
                return try await MainActor.run {
                    let descriptor = FetchDescriptor<PersistentCategory>()
                    let existingCategories = try modelContext.fetch(descriptor)
                    let existingCategoryIDs = Set(existingCategories.map { $0.id })
                    
                    for category in uniqueCategories {
                        if let existingCategory = existingCategories.first(where: { $0.id == category.id }) {
                            if existingCategory.name != category.name ||
                               existingCategory.emoji != category.emoji ||
                               existingCategory.direction != category.direction.rawValue {
                                print("Updating category: id=\(category.id), name=\(category.name), emoji=\(category.emoji), direction=\(category.direction)")
                                existingCategory.name = category.name
                                existingCategory.emoji = category.emoji
                                existingCategory.direction = category.direction.rawValue
                            }
                        } else {
                            print("Inserting new category: id=\(category.id), name=\(category.name), emoji=\(category.emoji), direction=\(category.direction)")
                            let persistentCategory = PersistentCategory(category: category)
                            modelContext.insert(persistentCategory)
                        }
                    }
                    
                    for existingCategory in existingCategories {
                        if !uniqueCategories.contains(where: { $0.id == existingCategory.id }) {
                            print("Deleting category: id=\(existingCategory.id)")
                            modelContext.delete(existingCategory)
                        }
                    }
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save categories in SwiftData: \(error)")
                        throw error
                    }
                    
                    return uniqueCategories
                }
            case .failure(let error):
                throw error
            }
        } catch {
            print("Network failed, fetching from local storage: \(error)")
            return try await MainActor.run {
                let descriptor = FetchDescriptor<PersistentCategory>()
                let persistentCategories = try modelContext.fetch(descriptor)
                let uniqueCategories = persistentCategories.map { $0.toCategory }.removingDuplicates(by: \.id)
                print("Returning \(uniqueCategories.count) unique categories from local storage")
                return uniqueCategories
            }
        }
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        let allCategories = try await categories()
        return allCategories.filter { $0.direction == direction }
    }
}
