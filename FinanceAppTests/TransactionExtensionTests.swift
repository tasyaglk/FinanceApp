//
//  TransactionExtensionTests.swift
//  FinanceAppTests
//
//  Created by Тася Галкина on 13.06.2025.
//

import XCTest
@testable import FinanceApp

final class TransactionExtensionTests: XCTestCase {
    
    // parse(jsonObject:)
    func testParseValidJson() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 11,
            "categoryId": 111,
            "amount": "1111.11",
            "transactionDate": "2025-06-13T12:00:00Z",
            "comment": "test",
            "createdAt": "2025-06-13T10:00:00Z",
            "updatedAt": "2025-06-13T11:00:00Z"
        ]
        
        let transaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.id, 1)
        XCTAssertEqual(transaction?.accountId, 11)
        XCTAssertEqual(transaction?.categoryId, 111)
        XCTAssertEqual(transaction?.amount, Decimal(string: "1111.11"))
        XCTAssertEqual(transaction?.comment, "test")
        
        let dateFormatter = ISO8601DateFormatter()
        XCTAssertEqual(transaction?.transactionDate, dateFormatter.date(from: "2025-06-13T12:00:00Z"))
        XCTAssertEqual(transaction?.createdAt, dateFormatter.date(from: "2025-06-13T10:00:00Z"))
        XCTAssertEqual(transaction?.updatedAt, dateFormatter.date(from: "2025-06-13T11:00:00Z"))
    }
    
    func testParseMissingRequiredField() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 11,
            "categoryId": 111,
            "amount": "1111.11",
            "comment": "test",
            "createdAt": "2025-06-13T10:00:00Z",
            "updatedAt": "2025-06-13T11:00:00Z"
        ]
        
        let transaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNil(transaction, "Transaction должен быть nil, если отсутствует обязательное поле")
    }
    
    func testParseInvalidAmount() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 11,
            "categoryId": 111,
            "amount": "invalid",
            "transactionDate": "2025-06-13T12:00:00Z",
            "comment": "test",
            "createdAt": "2025-06-13T10:00:00Z",
            "updatedAt": "2025-06-13T11:00:00Z"
        ]
        
        let transaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNil(transaction, "Transaction должен быть nil, если amount невалидный")
    }
    
    func testParseInvalidDate() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 11,
            "categoryId": 111,
            "amount": "1111.11",
            "transactionDate": "invalid",
            "comment": "test",
            "createdAt": "2025-06-13T10:00:00Z",
            "updatedAt": "2025-06-13T11:00:00Z"
        ]
        
        let transaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNil(transaction, "Transaction должен быть nil, если дата невалидная")
    }
    
    func testParseInvalidJson() {
        let json: Any = ["invalid": "data"]
        
        let transaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNil(transaction, "Transaction должен быть nil для невалидного JSON")
    }
    
    // jsonObject
    func testJsonObjectFullTransaction() {
        let dateFormatter = ISO8601DateFormatter()
        let transaction = Transaction(
            id: 1,
            accountId: 11,
            categoryId: 111,
            amount: Decimal(string: "11.11")!,
            transactionDate: dateFormatter.date(from: "2025-06-13T12:00:00Z")!,
            comment: "test",
            createdAt: dateFormatter.date(from: "2025-06-13T10:00:00Z")!,
            updatedAt: dateFormatter.date(from: "2025-06-13T11:00:00Z")!
        )
        
        let jsonObject = transaction.jsonObject as? [String: Any]
        
        XCTAssertNotNil(jsonObject)
        XCTAssertEqual(jsonObject?["id"] as? Int, 1)
        XCTAssertEqual(jsonObject?["accountId"] as? Int, 11)
        XCTAssertEqual(jsonObject?["categoryId"] as? Int, 111)
        XCTAssertEqual(jsonObject?["amount"] as? String, "11.11")
        XCTAssertEqual(jsonObject?["comment"] as? String, "test")
        XCTAssertEqual(jsonObject?["transactionDate"] as? String, "2025-06-13T12:00:00Z")
        XCTAssertEqual(jsonObject?["createdAt"] as? String, "2025-06-13T10:00:00Z")
        XCTAssertEqual(jsonObject?["updatedAt"] as? String, "2025-06-13T11:00:00Z")
    }
    
    func testJsonObjectNoCommentTransaction() {
        let dateFormatter = ISO8601DateFormatter()
        let transaction = Transaction(
            id: 1,
            accountId: 11,
            categoryId: 111,
            amount: Decimal(string: "11.11")!,
            transactionDate: dateFormatter.date(from: "2025-06-13T12:00:00Z")!,
            comment: nil,
            createdAt: dateFormatter.date(from: "2025-06-13T10:00:00Z")!,
            updatedAt: dateFormatter.date(from: "2025-06-13T11:00:00Z")!
        )
        
        let jsonObject = transaction.jsonObject as? [String: Any]
        
        XCTAssertNotNil(jsonObject)
        XCTAssertEqual(jsonObject?["id"] as? Int, 1)
        XCTAssertEqual(jsonObject?["accountId"] as? Int, 11)
        XCTAssertEqual(jsonObject?["categoryId"] as? Int, 111)
        XCTAssertEqual(jsonObject?["amount"] as? String, "11.11")
        XCTAssertNil(jsonObject?["comment"])
        XCTAssertEqual(jsonObject?["transactionDate"] as? String, "2025-06-13T12:00:00Z")
        XCTAssertEqual(jsonObject?["createdAt"] as? String, "2025-06-13T10:00:00Z")
        XCTAssertEqual(jsonObject?["updatedAt"] as? String, "2025-06-13T11:00:00Z")
    }
    
    // JSON -> Transaction -> JSON
    func testJsonToTransactionToJsonFull() {
        let originalJson: [String: Any] = [
            "id": 1,
            "accountId": 11,
            "categoryId": 111,
            "amount": "11.11",
            "transactionDate": "2025-06-13T12:00:00Z",
            "comment": "test",
            "createdAt": "2025-06-13T10:00:00Z",
            "updatedAt": "2025-06-13T11:00:00Z"
        ]
        
        let transaction = Transaction.parse(jsonObject: originalJson)
        let newJson = transaction?.jsonObject as? [String: Any]
        
        XCTAssertNotNil(newJson)
        XCTAssertEqual(newJson?["id"] as? Int, originalJson["id"] as? Int)
        XCTAssertEqual(newJson?["accountId"] as? Int, originalJson["accountId"] as? Int)
        XCTAssertEqual(newJson?["categoryId"] as? Int, originalJson["categoryId"] as? Int)
        
        if let newAmountString = newJson?["amount"] as? String, let originalAmountString = originalJson["amount"] as? String {
            XCTAssertEqual(Decimal(string: newAmountString), Decimal(string: originalAmountString))
        } else {
            XCTFail("amount должно быть в формате JSON")
        }
        
        XCTAssertEqual(newJson?["comment"] as? String, originalJson["comment"] as? String)
        if let newDateString = newJson?["transactionDate"] as? String, let originalDateString = originalJson["transactionDate"] as? String {
            XCTAssertEqual(newDateString, originalDateString)
        } else {
            XCTFail("transactionDate должно быть в формате JSON")
        }
        
        if let newDateString = newJson?["createdAt"] as? String, let originalDateString = originalJson["createdAt"] as? String {
            XCTAssertEqual(newDateString, originalDateString)
        } else {
            XCTFail("createdAt должно быть в формате JSON")
        }
        
        if let newDateString = newJson?["updatedAt"] as? String, let originalDateString = originalJson["updatedAt"] as? String {
            XCTAssertEqual(newDateString, originalDateString)
        } else {
            XCTFail("updatedAt должно быть в формате JSON")
        }
    }
    
    // Transaction -> JSON -> Transaction
    func testTransactionToJsonToTransactionFull() {
        let dateFormatter = ISO8601DateFormatter()
        let originalTransaction = Transaction(
            id: 1,
            accountId: 11,
            categoryId: 111,
            amount: Decimal(string: "11.11")!,
            transactionDate: dateFormatter.date(from: "2025-06-13T12:00:00Z")!,
            comment: "Test transaction",
            createdAt: dateFormatter.date(from: "2025-06-13T10:00:00Z")!,
            updatedAt: dateFormatter.date(from: "2025-06-13T11:00:00Z")!
        )
        
        let json = originalTransaction.jsonObject
        let newTransaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(newTransaction)
        XCTAssertEqual(newTransaction?.id, originalTransaction.id)
        XCTAssertEqual(newTransaction?.accountId, originalTransaction.accountId)
        XCTAssertEqual(newTransaction?.categoryId, originalTransaction.categoryId)
        XCTAssertEqual(newTransaction?.amount, originalTransaction.amount)
        XCTAssertEqual(newTransaction?.comment, originalTransaction.comment)
        XCTAssertEqual(newTransaction?.transactionDate, originalTransaction.transactionDate)
        XCTAssertEqual(newTransaction?.createdAt, originalTransaction.createdAt)
        XCTAssertEqual(newTransaction?.updatedAt, originalTransaction.updatedAt)
    }
}
