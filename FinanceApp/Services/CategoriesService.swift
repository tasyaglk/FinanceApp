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
            switch await client.categories() {
            case .success(let categories):
                print("Received \(categories.count) categories from network")
                let descriptor = FetchDescriptor<PersistentCategory>()
                let existingCategories = try modelContext.fetch(descriptor)
                
                let existingCategoryIDs = Set(existingCategories.map { $0.id })
                
                for category in categories {
                    if !existingCategoryIDs.contains(category.id) {
                        print("Inserting new category: id=\(category.id), name=\(category.name), emoji=\(category.emoji), direction=\(category.direction)")
                        let persistentCategory = PersistentCategory(category: category)
                        modelContext.insert(persistentCategory)
                    } else {
                        if let existingCategory = existingCategories.first(where: { $0.id == category.id }),
                           existingCategory.name != category.name ||
                           existingCategory.emoji != category.emoji ||
                           existingCategory.direction != category.direction.rawValue {
                            print("Updating category: id=\(category.id), name=\(category.name), emoji=\(category.emoji), direction=\(category.direction)")
                            existingCategory.name = category.name
                            existingCategory.emoji = category.emoji
                            existingCategory.direction = category.direction.rawValue
                        }
                    }
                }
                
                for existingCategory in existingCategories {
                    if !categories.contains(where: { $0.id == existingCategory.id }) {
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
                
                return categories
            case .failure(let error):
                throw error
            }
        } catch {
            print("Network failed, fetching from local storage: \(error)")
            let descriptor = FetchDescriptor<PersistentCategory>()
            let persistentCategories = try modelContext.fetch(descriptor)
            return persistentCategories.map { $0.toCategory }
        }
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        let allCategories = try await categories()
        return allCategories.filter { $0.direction == direction }
    }
}
