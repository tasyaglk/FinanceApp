//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Тася Галкина on 14.06.2025.
//

import Foundation

enum TransactionsServiceError: Error {
    case transactionExists(id: Int)
    case transactionNotFound(id: Int)
    case invalidTransaction
}

protocol TransactionsServiceProtocol {
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func createTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(withId id: Int) async throws
}

final class TransactionsService: TransactionsServiceProtocol {
    
    private var transactions: [Transaction]
    
    init() {
        transactions = [
            Transaction(
                id: 1,
                accountId: 1,
                categoryId: 1,
                amount: Decimal(string: "500.00"),
                transactionDate: Date(),
                comment: "зп",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: 2,
                accountId: 1,
                categoryId: 2,
                amount: Decimal(string: "200.50"),
                transactionDate: Date(),
                comment: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        return transactions.filter { transaction in
            guard let date = transaction.transactionDate else { return false }
            return date >= startDate && date <= endDate
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        guard let id = transaction.id else {
            throw TransactionsServiceError.invalidTransaction
        }
        
        if transactions.contains(where: { $0.id == id }) {
            throw TransactionsServiceError.transactionExists(id: id)
        }
        
        let newTransaction = Transaction(
            id: id,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        transactions.append(newTransaction)
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        
        guard let id = transaction.id else {
            throw TransactionsServiceError.invalidTransaction
        }
        
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionsServiceError.transactionNotFound(id: id)
        }
        
        let updatedTransaction = Transaction(
            id: id,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: transactions[index].createdAt,
            updatedAt: Date()
        )
        
        transactions[index] = updatedTransaction
    }
    
    func deleteTransaction(withId id: Int) async throws {
        
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionsServiceError.transactionNotFound(id: id)
        }
        
        transactions.remove(at: index)
    }
}
