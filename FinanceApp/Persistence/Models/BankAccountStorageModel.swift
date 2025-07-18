//
//  BankAccountStorageModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class BankAccountStorageModel {
    @Attribute(.unique) var id: Int
    var userId: Int
    var name: String
    var balance: String
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    var isSynced: Bool
    
    init(id: Int, userId: Int, name: String, balance: String, currency: String, createdAt: Date, updatedAt: Date, isSynced: Bool = false) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSynced = isSynced
    }
    
    func toBankAccount() throws -> BankAccount {
        guard let balanceDecimal = Decimal(string: balance) else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid balance format"]))
        }
        return BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balanceDecimal,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

