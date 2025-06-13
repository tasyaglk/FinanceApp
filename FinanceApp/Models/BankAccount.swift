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
    let balance: String?
    let currency: String?
    let createdAt: String?
    let updatedAt: String?
    
    var balanceDecimal: Decimal? {
        guard let balance = balance else { return nil }
        return Decimal(string: balance)
    }
    
    var createdAtDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return ISO8601DateFormatter().date(from: createdAt)
    }
    
    var updatedAtDate: Date? {
        guard let updatedAt = updatedAt else { return nil }
        return ISO8601DateFormatter().date(from: updatedAt)
    }
    
    init(id: Int? = nil, userId: Int? = nil, name: String? = nil, balance: String? = nil, currency: String? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
