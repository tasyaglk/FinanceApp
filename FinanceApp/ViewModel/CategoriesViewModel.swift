//
//  CategoriesViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 04.07.2025.
//

import Foundation

@MainActor
final class CategoriesViewModel: ObservableObject {
    private let categoriesService: CategoriesServiceProtocol = CategoriesService.shared
    
    @Published var categories: [Category] = []
    @Published var searchText = "" {
        didSet {
            updateFilteredCategories()
        }
    }
    @Published var filteredCategories: [Category] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    func fetchAllCategories() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.categories = try await categoriesService.categories()
            updateFilteredCategories()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка при загрузке категорий"
        }
    }
    
    private func updateFilteredCategories() {
        if searchText.isEmpty {
            filteredCategories = categories
        } else {
            let results = categories.map { category in
                (category: category, score: calculateFuzzyScore(searchText.lowercased(), category.name.lowercased()))
            }
            filteredCategories = results.filter { $0.score > 0.2 }
                .sorted { $0.score > $1.score }
                .map { $0.category }
        }
    }
    
    // inspired by https://www.objc.io/blog/2020/08/18/fuzzy-search/
    private func calculateFuzzyScore(_ search: String, _ target: String) -> Double {
        guard !search.isEmpty else { return 1.0 }
        guard !target.isEmpty else { return 0.0 }
        
        var searchIndex = search.startIndex
        var targetIndex = target.startIndex
        var consecutiveMatches = 0
        var totalScore = 0.0
        let searchLength = Double(search.count)
        let targetLength = Double(target.count)
        
        while searchIndex < search.endIndex && targetIndex < target.endIndex {
            let searchChar = search[searchIndex]
            var foundMatch = false
            
            while targetIndex < target.endIndex {
                let targetChar = target[targetIndex]
                if searchChar == targetChar {
                    consecutiveMatches += 1
                    totalScore += 1.0 + (Double(consecutiveMatches) * 0.05)
                    searchIndex = search.index(after: searchIndex)
                    foundMatch = true
                    break
                } else {
                    consecutiveMatches = 0
                    totalScore -= 0.01
                }
                targetIndex = target.index(after: targetIndex)
            }
            
            if !foundMatch && targetIndex >= target.endIndex {
                break
            }
        }
        
        let matchRatio = min(Double(search.distance(from: search.startIndex, to: searchIndex)) / searchLength, 1.0)
        totalScore = (totalScore / searchLength) * matchRatio
        
        if targetLength > searchLength {
            let lengthPenalty = (Double(targetLength - searchLength) / targetLength) * 0.3
            totalScore *= (1.0 - lengthPenalty)
        }
        
        return min(max(totalScore, 0.0), 1.0)
    }
}
