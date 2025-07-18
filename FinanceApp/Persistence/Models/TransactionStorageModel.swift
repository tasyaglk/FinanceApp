//
//  TransactionStorageModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class TransactionStorageModel {
    @Attribute(.unique) var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: String
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
    var isSynced: Bool
    
    init(id: Int, accountId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String?, createdAt: Date, updatedAt: Date, isSynced: Bool = false) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSynced = isSynced
    }
    
    func toTransaction() throws -> Transaction {
        guard let amountDecimal = Decimal(string: amount) else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid amount format"]))
        }
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amountDecimal,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

@Model
final class BackupTransactionModel {
    @Attribute(.unique) var id: Int
    var transaction: TransactionStorageModel
    var action: String
    
    init(id: Int, transaction: TransactionStorageModel, action: String) {
        self.id = id
        self.transaction = transaction
        self.action = action
    }
}
