//
//  CategoriesViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 04.07.2025.
//

import SwiftUI

@MainActor
final class CategoriesViewModel: ObservableObject {
    private let categoriesService: CategoriesServiceProtocol = CategoriesService()
    
    @Published var categories: [Category] = []
    
    init() {
        Task {
            await fetchAllCategories()
        }
    }
    
    func fetchAllCategories() async {
        do {
            self.categories = try await categoriesService.categories()
        } catch {
            print("error with fetching categories")
        }
    }
}
