//
//  CategoryStorageModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class CategoryStorageModel {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: Character
    var direction: Direction
    
    init(id: Int, name: String, emoji: Character, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }
    
    func toCategory() -> Category {
        return Category(
            id: id,
            name: name,
            emoji: emoji,
            direction: direction
        )
    }
}
