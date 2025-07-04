//
//  CurrencyTypes.swift
//  FinanceApp
//
//  Created by Тася Галкина on 27.06.2025.
//

import Foundation

enum CurrencyTypes: String, CaseIterable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"

    var symbol: String {
        switch self {
        case .rub:
            return "₽"
        case .usd:
            return "$"
        case .eur:
            return "€"
        }
    }
    
    var name: String {
        switch self {
        case .rub:
            return "Российский рубль"
        case .usd:
            return "Американский доллар"
        case .eur:
            return "Евро"
        }
    }
}
