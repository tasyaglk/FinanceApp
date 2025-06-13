//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Тася Галкина on 13.06.2025.
//

import Foundation

protocol CategoriesServiceProtocol {
    func categories() async throws -> [Category]
    func categories(direction: Direction) async throws -> [Category]
}

final class CategoriesService: CategoriesServiceProtocol {
    private let mockCategories: [Category] = [
        Category(id: 1, name: "зп", emoji: "💰", direction: .income),
        Category(id: 2, name: "репетиторство", emoji: "💻", direction: .income),
        Category(id: 3, name: "продукты", emoji: "🛒", direction: .outcome),
        Category(id: 4, name: "маникюр", emoji: "💅", direction: .outcome),
    ]
    
    func categories() async throws -> [Category] {
        return mockCategories
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        return mockCategories.filter { $0.direction == direction }
    }
}
