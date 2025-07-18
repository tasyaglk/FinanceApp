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
    
    private let client: BankAccountsClientProtocol
    
    private init() {
        self.client = BankAccountsClient(networkClient: NetworkClient())
    }
    
    func getBankAccount() async throws -> BankAccount? {
        switch await client.getBankAccount() {
        case .success(let account):
            return account
        case .failure(let error):
            throw error
        }
    }
    
    func updateBankAccount(_ account: BankAccount) async throws {
        switch await client.updateBankAccount(account) {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
