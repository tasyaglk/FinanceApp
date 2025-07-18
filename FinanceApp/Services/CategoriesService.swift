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
    static let shared = CategoriesService()
    
    private let client: CategoriesClientProtocol
    
    private init() {
        self.client = CategoriesClient(networkClient: NetworkClient())
    }
    
    func categories() async throws -> [Category] {
        switch await client.categories() {
        case .success(let categories):
            return categories
        case .failure(let error):
            throw error
        }
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        switch await client.categories(direction: direction) {
        case .success(let categories):
            return categories
        case .failure(let error):
            throw error
        }
    }
}
