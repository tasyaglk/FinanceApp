//
//  CategoryDTO.swift
//  FinanceApp
//
//  Created by Тася Галкина on 18.07.2025.
//

import Foundation

struct CategoryDTO: Codable {
    let id: Int
    let name: String
    let emoji: String
    let direction: Direction
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case direction
    }
    
    func toCategory() throws -> Category {
        guard let emojiChar = emoji.first, emoji.count == 1 else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid emoji format"]))
        }
        
        return Category(
            id: id,
            name: name,
            emoji: emojiChar,
            direction: direction
        )
    }
}
