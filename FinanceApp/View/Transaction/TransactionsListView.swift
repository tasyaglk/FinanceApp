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
    @State private var isAddButtonTapped = false
    @State private var selectedTransaction: Transaction? = nil
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: TransactionViewModel(direction: direction, customDates: false))
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
                            Picker(Constants.sortTitle, selection: $viewModel.sortOption) {
                                ForEach(SortOption.allCases) { option in
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
                                    .onTapGesture {
                                        selectedTransaction = transaction
                                    }
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
                                    isAddButtonTapped.toggle()
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .ignoresSafeArea()
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchInfo()
                }
            }
            .fullScreenCover(item: $selectedTransaction, onDismiss: {
                Task { await viewModel.fetchInfo() }
            }) { transaction in
                EditAndAddView(direction: viewModel.direction, transaction: transaction)
            }
            .fullScreenCover(isPresented: $isAddButtonTapped, onDismiss: {
                Task { await viewModel.fetchInfo() }
            }) {
                EditAndAddView(direction: viewModel.direction, transaction: nil)
            }
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
