//
//  TransactionsClient.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

protocol TransactionsClientProtocol {
    func fetchTransactions(accountId: Int, from startDate: Date, to endDate: Date) async -> Result<[Transaction], Error>
    func createTransaction(_ transaction: Transaction) async -> Result<Void, Error>
    func updateTransaction(_ transaction: Transaction) async -> Result<Void, Error>
    func deleteTransaction(withId id: Int) async -> Result<Void, Error>
}

final class TransactionsClient: TransactionsClientProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func fetchTransactions(accountId: Int, from startDate: Date, to endDate: Date) async -> Result<[Transaction], Error> {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            let endpoint = "/transactions/account/\(accountId)/period?startDate=\(start)&endDate=\(end)"
            let dtos: [TransactionResponseDTO] = try await networkClient.request(endpoint: endpoint, method: .get, body: nil as String?)
            let transactions = try dtos.map { try $0.toTransaction() }
            return .success(transactions)
        } catch {
            return .failure(error)
        }
    }
    
    func createTransaction(_ transaction: Transaction) async -> Result<Void, Error> {
        do {
            let requestDTO = TransactionRequestDTO(from: transaction)
            let responseDTO: TransactionDTO = try await networkClient.request(endpoint: "/transactions", method: .post, body: requestDTO)
            _ = try responseDTO.toTransaction() 
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async -> Result<Void, Error> {
        do {
            let requestDTO = TransactionRequestDTO(from: transaction)
            let responseDTO: TransactionResponseDTO = try await networkClient.request(endpoint: "/transactions/\(transaction.id)", method: .put, body: requestDTO)
            _ = try responseDTO.toTransaction()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func deleteTransaction(withId id: Int) async -> Result<Void, Error> {
        do {
            try await networkClient.requestWithoutResponse(endpoint: "/transactions/\(id)", method: .delete, body: nil as String?)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
