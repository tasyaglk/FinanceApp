//
//  CategoriesView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 04.07.2025.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel: CategoriesViewModel
    @State private var searchText = ""
    
    var filteredItems: [Category] {
        if searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: CategoriesViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                if !filteredItems.isEmpty {
                    List {
                        Section {
                            ForEach(filteredItems) { category in
                                CategoryRow(
                                    category: category
                                )
                            }
                        } header: {
                            Text("Статьи")
                                .font(.system(size: Constants.regularFontSize, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Мои статьи")
        }
    }
}
