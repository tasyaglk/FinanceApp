//
//  BankAccountRR.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

struct BankAccountCreateRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
    
    init(from account: BankAccount) {
        self.name = account.name
        self.balance = NSDecimalNumber(decimal: account.balance).stringValue
        self.currency = account.currency
    }
}

struct BankAccountUpdateRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
    
    init(from account: BankAccount) {
        self.name = account.name
        self.balance = NSDecimalNumber(decimal: account.balance).stringValue
        self.currency = account.currency
    }
}

struct AccountResponseDTO: Decodable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
    let incomeStats: [StatItemDTO]
    let expenseStats: [StatItemDTO]
    let createdAt: Date
    let updatedAt: Date
    
    func toBankAccount() throws -> BankAccount {
        guard let balanceDecimal = Decimal(string: balance) else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid balance format"]))
        }
        
        return BankAccount(
            id: id,
            userId: 79,
            name: name,
            balance: balanceDecimal,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct StatItemDTO: Decodable {
    let categoryId: Int
    let categoryName: String
    let emoji: String
    let amount: String
}
