//
//  BankAccountDTO.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

struct BankAccountDTO: Codable {
    let id: Int
    let userId: Int
    let name: String
    let balance: String
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "userId"
        case name
        case balance
        case currency
        case createdAt
        case updatedAt
    }
    
    func toBankAccount() throws -> BankAccount {
        guard let balanceDecimal = Decimal(string: balance) else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid balance format"]))
        }
        
        return BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balanceDecimal,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
