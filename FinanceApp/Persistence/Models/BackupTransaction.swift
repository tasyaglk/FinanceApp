//
//  BackupTransaction.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

enum BackupOperationType: String, Codable {
    case create
    case update
    case delete
}

@Model
class BackupTransaction {
    var id: Int
    var operationType: String
    var transaction: Transaction
    
    init(id: Int, operationType: BackupOperationType, transaction: Transaction) {
        self.id = id
        self.operationType = operationType.rawValue
        self.transaction = transaction
    }
}
