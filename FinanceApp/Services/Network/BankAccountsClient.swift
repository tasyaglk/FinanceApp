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
            print("Requesting GET /accounts")
            let accounts: [BankAccountDTO] = try await networkClient.request(endpoint: "/accounts", method: .get, body: nil as String?)
            print("Accounts received: \(accounts)")
            guard let accountDTO = accounts.first else {
                print("No bank accounts found")
                return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Счет не найден"]))
            }
            let account = try accountDTO.toBankAccount()
            print("Account converted: \(account)")
            return .success(account)
        } catch {
            print("Error fetching accounts as BankAccountDTO: \(error)")
            do {
                let accounts: [AccountResponseDTO] = try await networkClient.request(endpoint: "/accounts", method: .get, body: nil as String?)
                print("AccountResponseDTO received: \(accounts)")
                guard let accountDTO = accounts.first else {
                    print("No bank accounts found")
                    return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Счет не найден"]))
                }
                let account = try accountDTO.toBankAccount()
                print("Account converted from AccountResponseDTO: \(account)")
                return .success(account)
            } catch {
                print("Error decoding AccountResponseDTO: \(error)")
                return .failure(error)
            }
        }
    }
    
    func updateBankAccount(_ account: BankAccount) async -> Result<Void, Error> {
        do {
            let requestDTO = BankAccountUpdateRequest(from: account)
            print("Updating account with DTO: \(requestDTO)")
            try await networkClient.requestWithoutResponse(endpoint: "/accounts/\(account.id)", method: .put, body: requestDTO)
            print("Account updated successfully")
            return .success(())
        } catch {
            print("Error updating account: \(error)")
            return .failure(error)
        }
    }
}
