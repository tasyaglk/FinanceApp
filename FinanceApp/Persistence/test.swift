import SwiftData
import Foundation

// Protocol for transaction storage
//protocol TransactionStorageProtocol {
//    func fetchAll() throws -> [Transaction]
//    func update(_ transaction: Transaction) throws
//    func delete(id: Int) throws
//    func create(_ transaction: Transaction) throws
//    func saveBackup(_ transaction: Transaction, operationType: BackupOperationType) throws
//    func fetchBackup() throws -> [BackupTransaction]
//    func deleteBackup(id: Int) throws
//}

// Backup operation type
//enum BackupOperationType: String, Codable {
//    case create
//    case update
//    case delete
//}
//
//// Backup transaction model
//@Model
//class BackupTransaction {
//    var id: Int
//    var operationType: String
//    var transaction: Transaction
//    
//    init(id: Int, operationType: BackupOperationType, transaction: Transaction) {
//        self.id = id
//        self.operationType = operationType.rawValue
//        self.transaction = transaction
//    }
//}

// SwiftData transaction model
//@Model
//class PersistentTransaction {
//    var id: Int
//    var accountId: Int
//    var categoryId: Int
//    var amount: Decimal
//    var transactionDate: Date
//    var comment: String?
//    var createdAt: Date
//    var updatedAt: Date
//    
//    init(transaction: Transaction) {
//        self.id = transaction.id
//        self.accountId = transaction.accountId
//        self.categoryId = transaction.categoryId
//        self.amount = transaction.amount
//        self.transactionDate = transaction.transactionDate
//        self.comment = transaction.comment
//        self.createdAt = transaction.createdAt
//        self.updatedAt = transaction.updatedAt
//    }
//    
//    var toTransaction: Transaction {
//        Transaction(
//            id: id,
//            accountId: accountId,
//            categoryId: categoryId,
//            amount: amount,
//            transactionDate: transactionDate,
//            comment: comment,
//            createdAt: createdAt,
//            updatedAt: updatedAt
//        )
//    }
//}

// SwiftData bank account model
//@Model
//class PersistentBankAccount {
//    var id: Int
//    var userId: Int
//    var name: String
//    var balance: Decimal
//    var currency: String
//    var createdAt: Date
//    var updatedAt: Date
//    
//    init(account: BankAccount) {
//        self.id = account.id
//        self.userId = account.userId
//        self.name = account.name
//        self.balance = account.balance
//        self.currency = account.currency
//        self.createdAt = account.createdAt
//        self.updatedAt = account.updatedAt
//    }
//    
//    var toBankAccount: BankAccount {
//        BankAccount(
//            id: id,
//            userId: userId,
//            name: name,
//            balance: balance,
//            currency: currency,
//            createdAt: createdAt,
//            updatedAt: updatedAt
//        )
//    }
//}

// SwiftData category model
//@Model
//class PersistentCategory {
//    var id: Int
//    var name: String
//    var emoji: Character
//    var direction: String
//    
//    init(category: Category) {
//        self.id = category.id
//        self.name = category.name
//        self.emoji = category.emoji
//        self.direction = category.direction.rawValue
//    }
//    
//    var toCategory: Category {
//        Category(
//            id: id,
//            name: name,
//            emoji: emoji,
//            direction: Direction(rawValue: direction)!
//        )
//    }
//}

// Transaction storage implementation
//class TransactionStorage: TransactionStorageProtocol {
//    private let modelContainer: ModelContainer
//    private let modelContext: ModelContext
//    
//    init() throws {
//        let schema = Schema([PersistentTransaction.self, BackupTransaction.self, PersistentBankAccount.self, PersistentCategory.self])
//        self.modelContainer = try ModelContainer(for: schema)
//        self.modelContext = ModelContext(modelContainer)
//    }
//    
//    func fetchAll() throws -> [Transaction] {
//        let descriptor = FetchDescriptor<PersistentTransaction>()
//        let persistentTransactions = try modelContext.fetch(descriptor)
//        return persistentTransactions.map { $0.toTransaction }
//    }
//    
//    func update(_ transaction: Transaction) throws {
//        let predicate = #Predicate<PersistentTransaction> { $0.id == transaction.id }
//        let descriptor = FetchDescriptor<PersistentTransaction>(predicate: predicate)
//        guard let existingTransaction = try modelContext.fetch(descriptor).first else {
//            throw TransactionsServiceError.transactionNotFound(id: transaction.id)
//        }
//        
//        existingTransaction.accountId = transaction.accountId
//        existingTransaction.categoryId = transaction.categoryId
//        existingTransaction.amount = transaction.amount
//        existingTransaction.transactionDate = transaction.transactionDate
//        existingTransaction.comment = transaction.comment
//        existingTransaction.createdAt = transaction.createdAt
//        existingTransaction.updatedAt = transaction.updatedAt
//        
//        try modelContext.save()
//    }
//    
//    func delete(id: Int) throws {
//        let predicate = #Predicate<PersistentTransaction> { $0.id == id }
//        let descriptor = FetchDescriptor<PersistentTransaction>(predicate: predicate)
//        guard let transaction = try modelContext.fetch(descriptor).first else {
//            throw TransactionsServiceError.transactionNotFound(id: id)
//        }
//        modelContext.delete(transaction)
//        try modelContext.save()
//    }
//    
//    func create(_ transaction: Transaction) throws {
//        let persistentTransaction = PersistentTransaction(transaction: transaction)
//        modelContext.insert(persistentTransaction)
//        try modelContext.save()
//    }
//    
//    func saveBackup(_ transaction: Transaction, operationType: BackupOperationType) throws {
//        let backup = BackupTransaction(id: transaction.id, operationType: operationType, transaction: transaction)
//        modelContext.insert(backup)
//        try modelContext.save()
//    }
//    
//    func fetchBackup() throws -> [BackupTransaction] {
//        let descriptor = FetchDescriptor<BackupTransaction>()
//        return try modelContext.fetch(descriptor)
//    }
//    
//    func deleteBackup(id: Int) throws {
//        let predicate = #Predicate<BackupTransaction> { $0.id == id }
//        let descriptor = FetchDescriptor<BackupTransaction>(predicate: predicate)
//        let backups = try modelContext.fetch(descriptor)
//        backups.forEach { modelContext.delete($0) }
//        try modelContext.save()
//    }
//}

// Bank account storage protocol
//protocol BankAccountStorageProtocol {
//    func getAccount() throws -> BankAccount?
//    func update(_ account: BankAccount) throws
//    func saveBackup(_ account: BankAccount, operationType: BackupOperationType) throws
//    func fetchBackup() throws -> [BackupTransaction]
//    func deleteBackup(id: Int) throws
//}

// Bank account storage implementation
//class BankAccountStorage: BankAccountStorageProtocol {
//    private let modelContext: ModelContext
//    
//    init(modelContainer: ModelContainer) {
//        self.modelContext = ModelContext(modelContainer)
//    }
//    
//    func getAccount() throws -> BankAccount? {
//        let descriptor = FetchDescriptor<PersistentBankAccount>()
//        return try modelContext.fetch(descriptor).first?.toBankAccount
//    }
//    
//    func update(_ account: BankAccount) throws {
//        let predicate = #Predicate<PersistentBankAccount> { $0.id == account.id }
//        let descriptor = FetchDescriptor<PersistentBankAccount>(predicate: predicate)
//        if let existingAccount = try modelContext.fetch(descriptor).first {
//            existingAccount.name = account.name
//            existingAccount.balance = account.balance
//            existingAccount.currency = account.currency
//            existingAccount.updatedAt = account.updatedAt
//        } else {
//            let persistentAccount = PersistentBankAccount(account: account)
//            modelContext.insert(persistentAccount)
//        }
//        try modelContext.save()
//    }
//    
//    func saveBackup(_ account: BankAccount, operationType: BackupOperationType) throws {
//        let backup = BackupTransaction(id: account.id, operationType: operationType, transaction: Transaction(id: account.id, accountId: account.id, categoryId: 0, amount: account.balance, transactionDate: account.updatedAt, createdAt: account.createdAt, updatedAt: account.updatedAt))
//        modelContext.insert(backup)
//        try modelContext.save()
//    }
//    
//    func fetchBackup() throws -> [BackupTransaction] {
//        let descriptor = FetchDescriptor<BackupTransaction>()
//        return try modelContext.fetch(descriptor)
//    }
//    
//    func deleteBackup(id: Int) throws {
//        let predicate = #Predicate<BackupTransaction> { $0.id == id }
//        let descriptor = FetchDescriptor<BackupTransaction>(predicate: predicate)
//        let backups = try modelContext.fetch(descriptor)
//        backups.forEach { modelContext.delete($0) }
//        try modelContext.save()
//    }
//}
