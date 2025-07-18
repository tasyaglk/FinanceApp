//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Тася Галкина on 14.06.2025.
//

import Foundation

enum TransactionsServiceError: Error, LocalizedError {
    case transactionExists(id: Int)
    case transactionNotFound(id: Int)
    case invalidTransaction
    case accountNotFound
    
    var errorDescription: String? {
        switch self {
        case .transactionExists(let id):
            return "Транзакция с ID \(id) уже существует"
        case .transactionNotFound(let id):
            return "Транзакция с ID \(id) не найдена"
        case .invalidTransaction:
            return "Неверные данные транзакции"
        case .accountNotFound:
            return "Счет не найден"
        }
    }
}

protocol TransactionsServiceProtocol {
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func createTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(withId id: Int) async throws
    func getId() -> Int
}

final class TransactionsService: TransactionsServiceProtocol {
    static let shared = TransactionsService()
    
    private let client: TransactionsClientProtocol
    private let bankAccountsClient: BankAccountsClientProtocol
    private var transactions: [Transaction] = []
    
    private init() {
        let networkClient = NetworkClient()
        self.client = TransactionsClient(networkClient: networkClient)
        self.bankAccountsClient = BankAccountsClient(networkClient: networkClient)
    }
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        switch await bankAccountsClient.getBankAccount() {
        case .success(let account):
            switch await client.fetchTransactions(accountId: account.id, from: startDate, to: endDate) {
            case .success(let transactions):
                self.transactions = transactions
                return transactions
            case .failure(let error):
                throw error
            }
        case .failure:
            throw TransactionsServiceError.accountNotFound
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        if transactions.contains(where: { $0.id == transaction.id }) {
            throw TransactionsServiceError.transactionExists(id: transaction.id)
        }
        switch await client.createTransaction(transaction) {
        case .success:
            transactions.append(transaction)
            try await updateAccountBalance()
        case .failure(let error):
            if case NetworkError.requestFailed(statusCode: 404, _) = error {
                throw TransactionsServiceError.invalidTransaction
            }
            throw error
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionsServiceError.transactionNotFound(id: transaction.id)
        }
        switch await client.updateTransaction(transaction) {
        case .success:
            transactions[index] = transaction
            try await updateAccountBalance()
        case .failure(let error):
            if case NetworkError.requestFailed(statusCode: 404, _) = error {
                throw TransactionsServiceError.transactionNotFound(id: transaction.id)
            }
            throw error
        }
    }
    
    func deleteTransaction(withId id: Int) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionsServiceError.transactionNotFound(id: id)
        }
        switch await client.deleteTransaction(withId: id) {
        case .success:
            transactions.remove(at: index)
            try await updateAccountBalance()
        case .failure(let error):
            if case NetworkError.requestFailed(statusCode: 404, _) = error {
                throw TransactionsServiceError.transactionNotFound(id: id)
            }
            throw error
        }
    }
    
    func getId() -> Int {
        return (transactions.map { $0.id }.max() ?? 0) + 1
    }
    
    private func updateAccountBalance() async throws {
        switch await bankAccountsClient.getBankAccount() {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
