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
                VStack {
                    Section {
                        ForEach(viewModel.categories) { category in
                            Text("\(category.name)")
                            //                        TransactionRow(
                            //                            category: viewModel.categories[transaction.categoryId],
                            //                            transaction: transaction
                            //                        )
                        }
                    } header: {
                        Text("Статьи")
                            .font(.system(size: Constants.regularFontSize, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Мои статьи")
        }
    }
}
