//
//  HistoryView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 21.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: TransactionViewModel
    @State private var localStartDate: Date = Date()
    @State private var localEndDate: Date = Date()
    @State private var isAnalysisTapped = false
    @State private var selectedTransaction: Transaction? = nil
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: TransactionViewModel(direction: direction, customDates: true))
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Text(Constants.historyTitle)
                            .font(.system(size: Constants.titleFontSize, weight: .bold))
                        Spacer()
                    }
                }
                .padding(.horizontal, Constants.padding)
                
                List {
                    Section {
                        HStack {
                            Text(Constants.beginTitle)
                            Spacer()
                            DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                                .onChange(of: viewModel.startDate) { _, newValue in
                                    if viewModel.endDate < newValue {
                                        viewModel.endDate = newValue
                                    }
                                    Task {
                                        await viewModel.fetchInfo()
                                    }
                                }
                                .background(Color.lightMain)
                                .labelsHidden()
                                .cornerRadius(Constants.cornerRadius)
                        }
                        HStack {
                            Text(Constants.endTitle)
                            Spacer()
                            DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                                .onChange(of: viewModel.endDate) { _, newValue in
                                    if viewModel.startDate > newValue {
                                        viewModel.startDate = newValue
                                    }
                                    Task {
                                        await viewModel.fetchInfo()
                                    }
                                }
                                .background(Color.lightMain)
                                .labelsHidden()
                                .cornerRadius(Constants.cornerRadius)
                        }
                        Picker(Constants.sortTitle, selection: $viewModel.sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .tint(.black)
                        .pickerStyle(.menu)
                        TotalCellView(title: Constants.amountTitle, total: viewModel.totalAmount, symbol: viewModel.currency)
                    }
                    
                    if !viewModel.transactions.isEmpty {
                        Section {
                            ForEach(viewModel.transactions) { transaction in
                                TransactionRow(
                                    category: viewModel.categories[transaction.categoryId],
                                    transaction: transaction, symbol: viewModel.currency
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .ignoresSafeArea()
                }
            }
            .alert("ошибка", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("ок", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "оаоаоа а что говорить...")
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
                        isAnalysisTapped.toggle()
                    }) {
                        Image(systemName: "doc")
                            .tint(.button)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isAnalysisTapped) {
                AnalysisViewControllerRepresentable(
                    direction: viewModel.direction,
                    startDate: viewModel.startDate,
                    endDate: viewModel.endDate
                )
                .background(Color.background)
                .ignoresSafeArea(edges: .all)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
            }
        }
    }
}
