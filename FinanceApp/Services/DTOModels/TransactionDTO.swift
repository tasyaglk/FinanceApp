//
//  TransactionDTO.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

struct TransactionDTO: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
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
