//
//  BankAccountsService.swift
//  FinanceApp
//
//  Created by Тася Галкина on 13.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
    func getBankAccount() async throws -> BankAccount?
    func updateBankAccount(_ account: BankAccount) async throws
}

final class BankAccountsService: BankAccountsServiceProtocol {
    static let shared = BankAccountsService()
        
        private init() {}
    
    private var mockAccounts: [BankAccount] = [
        BankAccount(
            id: 1,
            userId: 1,
            name: "карта зп",
            balance: 50000,
            currency: "₽",
            createdAt: Date(),
            updatedAt: Date()
        ),
        BankAccount(
            id: 2,
            userId: 1,
            name: "карта для путешествий",
            balance: 100,
            currency: "$",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    func getBankAccount() async throws -> BankAccount? {
        return mockAccounts.first
    }
    
    func updateBankAccount(_ account: BankAccount) async throws {
        mockAccounts[0] = account
    }
}
