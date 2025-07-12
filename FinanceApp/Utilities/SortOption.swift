//
//  SortOption.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case date = "дата"
    case amount = "сумма"
    
    var id: String { rawValue }
}
