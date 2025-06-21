//
//  HistoryView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 21.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: HistoryViewModel
    
    @State private var localStartDate: Date = Date()
    @State private var localEndDate: Date = Date()
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(direction: direction))
    }
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack {
                    
                    HStack {
                        Text(Constants.historyTitle)
                            .font(.system(size: 34, weight: .bold))
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                
                List {
                    Section {
                        DatePicker(Constants.beginTitle, selection: $viewModel.startDate, displayedComponents: .date)
                            .onChange(of: viewModel.startDate, {
                                Task {
                                    await viewModel.fetchInfo()
                                }
                            })
                        
                        DatePicker(Constants.endTitle, selection: $viewModel.endDate, displayedComponents: .date)
                            .onChange(of: viewModel.endDate, {
                                Task { await viewModel.fetchInfo()
                                }
                            })
                        
                        Picker("Сортировка", selection: $viewModel.sortOption) {
                            ForEach(TransactionSortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .tint(.black)
                        .pickerStyle(.menu)
                        
                        TotalCellView(title: Constants.amountTitle, total: viewModel.totalAmount)
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
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(Constants.backTitle)
                    }
                    .tint(.button)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("doc")
                }) {
                    Image(systemName: "doc")
                        .tint(.button)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
