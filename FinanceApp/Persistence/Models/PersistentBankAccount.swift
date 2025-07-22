//
//  PersistentBankAccount.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

@Model
class PersistentBankAccount {
    var id: Int
    var userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(account: BankAccount) {
        self.id = account.id
        self.userId = account.userId
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }
    
    var toBankAccount: BankAccount {
        BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
