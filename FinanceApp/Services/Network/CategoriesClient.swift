//
//  CategoriesClient.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

import Foundation

protocol CategoriesClientProtocol {
    func categories() async -> Result<[Category], Error>
    func categories(direction: Direction) async -> Result<[Category], Error>
}

final class CategoriesClient: CategoriesClientProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func categories() async -> Result<[Category], Error> {
        do {
            let dtos: [CategoryDTO] = try await networkClient.request(endpoint: "/categories", method: .get, body: nil as String?)
            let categories = try dtos.map { try $0.toCategory() }
            return .success(categories)
        } catch {
            return .failure(error)
        }
    }
    
    func categories(direction: Direction) async -> Result<[Category], Error> {
        do {
            let endpoint = "/categories/type/\(direction == .income ? "true" : "false")"
            let dtos: [CategoryDTO] = try await networkClient.request(endpoint: endpoint, method: .get, body: nil as String?)
            let categories = try dtos.map { try $0.toCategory() }
            return .success(categories)
        } catch {
            return .failure(error)
        }
    }
}
