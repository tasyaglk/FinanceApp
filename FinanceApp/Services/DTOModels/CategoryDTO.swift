//
//  CategoryDTO.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

struct CategoryDTO: Decodable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    func toCategory() throws -> Category {
        guard let emojiChar = emoji.first, emoji.count == 1 else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid emoji format"]))
        }
        return Category(
            id: id,
            name: name,
            emoji: emojiChar,
            direction: isIncome ? .income : .outcome
        )
    }
}
