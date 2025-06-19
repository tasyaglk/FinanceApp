//
//  Category.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.06.2025.
//

import Foundation

enum Direction: String, Codable {
    case income
    case outcome
}

struct Category: Identifiable, Codable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
    
    var isIncome: Bool {
        direction == .income
    }
    
    init(id: Int, name: String, emoji: Character, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }
}
