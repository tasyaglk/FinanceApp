//
//  TransactionRR.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

struct TransactionRequestDTO: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: Date
    let comment: String
    
    init(from transaction: Transaction) {
        self.accountId = transaction.accountId
        self.categoryId = transaction.categoryId
        self.amount = NSDecimalNumber(decimal: transaction.amount).stringValue
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment ?? ""
    }
}

struct TransactionResponseDTO: Decodable {
    let id: Int
    let account: AccountBriefDTO
    let category: CategoryDTO
    let amount: String
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
    
    func toTransaction() throws -> Transaction {
        guard let amountDecimal = Decimal(string: amount) else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid amount format"]))
        }
        return Transaction(
            id: id,
            accountId: account.id,
            categoryId: category.id,
            amount: amountDecimal,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct AccountBriefDTO: Decodable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}
