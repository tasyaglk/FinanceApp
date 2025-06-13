//
//  TransactionsFileCache.swift
//  FinanceApp
//
//  Created by Тася Галкина on 12.06.2025.
//

import Foundation

enum FileCacheError: Error {
    case documentsDirectoryNotFound
    case invalidJsonFormat
}

final class TransactionsFileCache {
    private(set) var transactions: [Transaction]
    
    private let fileURL: URL
    
    init(fileName: String) throws {
        self.transactions = []
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.documentsDirectoryNotFound
        }
        self.fileURL = documentsURL.appendingPathComponent(fileName)
    }
    
    func addTransaction(_ transaction: Transaction) -> Bool {
        guard let id = transaction.id else { return false }
        guard !transactions.contains(where: { $0.id == id }) else { return false }
        
        transactions.append(transaction)
        return true
    }
    
    func removeTransaction(withId id: Int) -> Bool {
        let initialCount = transactions.count
        transactions.removeAll { $0.id == id }
        let wasRemoved = transactions.count < initialCount
        
        return wasRemoved
    }
    
    func saveTransactions() {
        do {
            let jsonArray = transactions.map { $0.jsonObject }
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            try data.write(to: fileURL)
        } catch {
            print("ошибка сохранения транзакций по адресу \(fileURL): \(error)")
        }
    }
    
    func loadTransactions() {
        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
            let data = try Data(contentsOf: fileURL)
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: [])
            guard let array = jsonArray as? [[String: Any]] else {
                throw FileCacheError.invalidJsonFormat
            }
            transactions = array.compactMap { Transaction.parse(jsonObject: $0) }
        } catch {
            print("ошибка загрузки транзакций по адресу \(fileURL): \(error)")
            transactions = []
        }
    }
}
