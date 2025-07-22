//
//  BankAccountsClient.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

import Foundation

protocol BankAccountsClientProtocol {
    func getBankAccount() async -> Result<BankAccount, Error>
    func updateBankAccount(_ account: BankAccount) async -> Result<Void, Error>
}

final class BankAccountsClient: BankAccountsClientProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func getBankAccount() async -> Result<BankAccount, Error> {
        do {
            let accounts: [BankAccountDTO] = try await networkClient.request(endpoint: "/accounts", method: .get, body: nil as String?)
            guard let accountDTO = accounts.first else {
                return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Счет не найден"]))
            }
            let account = try accountDTO.toBankAccount()
            return .success(account)
        } catch {
            do {
                let accounts: [AccountResponseDTO] = try await networkClient.request(endpoint: "/accounts", method: .get, body: nil as String?)
                guard let accountDTO = accounts.first else {
                    return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Счет не найден"]))
                }
                let account = try accountDTO.toBankAccount()
                return .success(account)
            } catch {
                return .failure(error)
            }
        }
    }
    
    func updateBankAccount(_ account: BankAccount) async -> Result<Void, Error> {
        do {
            let requestDTO = BankAccountUpdateRequest(from: account)
            try await networkClient.requestWithoutResponse(endpoint: "/accounts/\(account.id)", method: .put, body: requestDTO)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
