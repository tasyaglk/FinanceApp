//
//  Transaction.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.06.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
    
    init(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String? = nil, createdAt: Date, updatedAt: Date) {
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
            return nil
        }
        
        guard let id = dict["id"] as? Int,
        let accountId = dict["accountId"] as? Int,
        let categoryId = dict["categoryId"] as? Int,
        let comment = dict["comment"] as? String,
        let createdAtString = dict["createdAt"] as? String,
        let updatedAtString = dict["updatedAt"] as? String,
        let amountString = dict["amount"] as? String,
        let transactionDateString = dict["transactionDate"] as? String
        else {
            return nil
        }
        
        
        let dateFormatter = ISO8601DateFormatter()
        
        guard let createdAt = dateFormatter.date(from: createdAtString),
        let updatedAt = dateFormatter.date(from: updatedAtString),
        let transactionDate = dateFormatter.date(from: transactionDateString),
        let amount = Decimal(string: amountString)
        else {
            return nil
        }
        
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
    
    var jsonObject: [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["id"] = id
        dict["accountId"] = accountId
        dict["categoryId"] = categoryId
        dict["amount"] = NSDecimalNumber(decimal: amount).stringValue
        dict["comment"] = comment 
        
        let dateFormatter = ISO8601DateFormatter()
        
        dict["transactionDate"] = dateFormatter.string(from: transactionDate)
        dict["createdAt"] = dateFormatter.string(from: createdAt)
        dict["updatedAt"] = dateFormatter.string(from: updatedAt)
        
        return dict
    }
}

extension Transaction {
    static func parseCSV(_ csvString: String) -> Transaction? {
        let line = csvString.components(separatedBy: ",").filter { !$0.isEmpty }
        guard line.count >= 6 else { return nil }
        
        let dateFormatter = ISO8601DateFormatter()
        
        guard let id = Int(line[0]),
              let accountId = Int(line[1]),
              let categoryId = Int(line[2]),
              let amount = line[3].isEmpty ? nil : Decimal(string: line[3]),
              let transactionDate = line[4].isEmpty ? nil : dateFormatter.date(from: line[4]),
              let comment = line[5].isEmpty ? nil : line[5],
              let createdAt = line.isEmpty ? nil : dateFormatter.date(from: line[6]),
              let updatedAt = line[7].isEmpty ? nil : dateFormatter.date(from: line[7])
        else {
            return nil
        }
        
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
}
