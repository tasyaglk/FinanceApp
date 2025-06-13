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
    let amount: Decimal?
    let transactionDate: Date?
    let comment: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(id: Int?, accountId: Int?, categoryId: Int?, amount: Decimal?, transactionDate: Date?, comment: String?, createdAt: Date?, updatedAt: Date?) {
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
        guard
            JSONSerialization.isValidJSONObject(jsonObject),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject)
        else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Transaction.self, from: data)
    }
    
    var jsonObject: Any {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self),
              var dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        else { return [:] }
        dict.keys.forEach { key in
            if dict[key] is NSNull { dict.removeValue(forKey: key) }
        }
        return dict
    }
}
