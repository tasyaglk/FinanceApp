//
//  BankAccount.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.06.2025.
//

import Foundation

struct BankAccount: Identifiable, Codable {
    let id: Int?
    let userId: Int?
    let name: String?
    let balance: Decimal?
    let currency: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(id: Int? = nil, userId: Int? = nil, name: String? = nil, balance: Decimal? = nil, currency: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
