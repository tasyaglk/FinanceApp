//
//  PersistentCategory.swift
//  FinanceApp
//
//  Created by Тася Галкина on 19.07.2025.
//

import Foundation
import SwiftData

@Model
class PersistentCategory {
    var id: Int
    var name: String
    var emoji: Character
    var direction: String
    
    init(category: Category) {
        self.id = category.id
        self.name = category.name
        self.emoji = category.emoji
        self.direction = category.direction.rawValue
    }
    
    var toCategory: Category {
        Category(
            id: id,
            name: name,
            emoji: emoji,
            direction: Direction(rawValue: direction)!
        )
    }
}
