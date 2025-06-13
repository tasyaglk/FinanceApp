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
        guard let dict = jsonObject as? [String: Any] else {
            return Transaction(
                id: nil,
                accountId: nil,
                categoryId: nil,
                amount: nil,
                transactionDate: nil,
                comment: nil,
                createdAt: nil,
                updatedAt: nil
            )
        }
        
        let id = dict["id"] as? Int
        let accountId = dict["accountId"] as? Int
        let categoryId = dict["categoryId"] as? Int
        let comment = dict["comment"] as? String
        let createdAtString = dict["createdAt"] as? String
        let updatedAtString = dict["updatedAt"] as? String
        let amountString = dict["amount"] as? String
        let transactionDateString = dict["transactionDate"] as? String
        
        
        let dateFormatter = ISO8601DateFormatter()
        
        
        let createdAt = createdAtString != nil ? dateFormatter.date(from: createdAtString ?? "") : nil
        let updatedAt = updatedAtString != nil ? dateFormatter.date(from: updatedAtString ?? "") : nil
        let transactionDate = transactionDateString != nil ? dateFormatter.date(from: transactionDateString ?? "") : nil
        
        let amount = amountString != nil ? Decimal(string: amountString ?? "") : nil
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    var jsonObject: Any {
        var dict: [String: Any] = [:]
        
        if let id = id {
            dict["id"] = id
        }
        if let accountId = accountId {
            dict["accountId"] = accountId
        }
        if let categoryId = categoryId {
            dict["categoryId"] = categoryId
        }
        if let amount = amount {
            dict["amount"] = String(describing: amount)
        }
        if let comment = comment {
            dict["comment"] = comment
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        if let transactionDate = transactionDate {
            dict["transactionDate"] = dateFormatter.string(from: transactionDate)
        }
        if let createdAt = createdAt {
            dict["createdAt"] = dateFormatter.string(from: createdAt)
        }
        if let updatedAt = updatedAt {
            dict["updatedAt"] = dateFormatter.string(from: updatedAt)
        }
        
        return dict
    }
}
