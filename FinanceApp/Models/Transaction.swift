//
//  Transaction.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.06.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: Int?
    let accountId: Int?
    let categoryId: Int?
    let amount: String?
    let transactionDate: String?
    let comment: String?
    let createdAt: String?
    let updatedAt: String?
    var amountDecimal: Decimal? {
        guard let amount = amount else { return nil }
        return Decimal(string: amount)
    }
    
    var transactionDateValue: Date? {
        guard let transactionDate = transactionDate else { return nil }
        return ISO8601DateFormatter().date(from: transactionDate)
    }
    
    var createdAtDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return ISO8601DateFormatter().date(from: createdAt)
    }
    
    var updatedAtDate: Date? {
        guard let updatedAt = updatedAt else { return nil }
        return ISO8601DateFormatter().date(from: updatedAt)
    }
    
    init(id: Int?, accountId: Int?, categoryId: Int?, amount: String?, transactionDate: String?, comment: String?, createdAt: String?, updatedAt: String?) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
            return try JSONDecoder().decode(Transaction.self, from: jsonData)
        } catch {
            print("Parse error: \(error)")
            return nil
        }
    }
    
    var jsonObject: Any {
        do {
            let jsonData = try JSONEncoder().encode(self)
            var dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            if comment == nil { dict["comment"] = nil }
            return dict
        } catch {
            print("JsonObject error: \(error)")
            return [:]
        }
    }
}
