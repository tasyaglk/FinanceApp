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
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .ignoresSafeArea()
                }
            }
            .task {
                await viewModel.fetchAllCategories()
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle(Constants.categoryTitle)
            .alert("ошибка", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("ок", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "оаоаоа а что говорить...")
            }
        }
    }
}
