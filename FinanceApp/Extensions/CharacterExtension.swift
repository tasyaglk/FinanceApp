//
//  CharacterExtension.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.06.2025.
//

import Foundation

extension Character: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard string.count == 1, let character = string.first else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "expected only one emoji")
        }
        self = character
    }
}
