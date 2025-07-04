//
//  CategoriesView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 04.07.2025.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel: CategoriesViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: CategoriesViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                if !viewModel.filteredCategories.isEmpty {
                    List {
                        Section {
                            ForEach(viewModel.filteredCategories) { category in
                                CategoryRow(
                                    category: category
                                )
                            }
                        } header: {
                            Text(Constants.categories)
                                .font(.system(size: Constants.regularFontSize, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle(Constants.categoryTitle)
        }
    }
}
