//
//  TransactionsListView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @StateObject private var viewModel: TransactionViewModel
    @State private var isHistoryTapped = false
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: TransactionViewModel(direction: direction))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Text(viewModel.direction == .income ? Constants.incomeTitle : Constants.outcomeTitle)
                            .font(.system(size: CGFloat(Constants.titleFontSize), weight: .bold))
                        
                        Spacer()
                    }
                    .padding(.horizontal, Constants.padding)
                    
                    List {
                        Section {
                            Picker("Сортировка", selection: $viewModel.sortOption) {
                                ForEach(TransactionSortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .tint(.black)
                            .pickerStyle(.menu)
                            TotalCellView(title: Constants.total, total: viewModel.totalAmount)
                        }
                        
                        if !viewModel.transactions.isEmpty {
                            Section {
                                ForEach(viewModel.transactions) { transaction in
                                    TransactionRow(
                                        category: viewModel.categories[transaction.categoryId],
                                        transaction: transaction
                                    )
                                }
                            } header: {
                                Text(Constants.operationTitle)
                                    .font(.system(size: Constants.regularFontSize, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    Spacer()
                }
                .overlay(
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    print("add button tapped")
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                                        .foregroundColor(.main)
                                        .background(.white)
                                        .clipShape(Circle())
                                }
                                .padding(.bottom, Constants.padding)
                                .padding(.trailing, Constants.padding)
                            }
                        }
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isHistoryTapped.toggle()
                        }) {
                            Image(systemName: "clock")
                                .tint(.button)
                        }
                    }
                }
                .navigationBarHidden(false)
                .navigationDestination(isPresented: $isHistoryTapped) {
                    HistoryView(direction: viewModel.direction)
                }
            }
        }
    }
}
