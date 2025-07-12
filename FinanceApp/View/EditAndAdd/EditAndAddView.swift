//
//  EditAndAddView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 12.07.2025.
//

import SwiftUI

struct EditAndAddView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EditAndAddViewModel
    @FocusState private var isAmountFieldFocused: Bool
    @State private var showCategoryPicker = false
    
    
    init(direction: Direction, transaction: Transaction? = nil) {
        _viewModel = StateObject(wrappedValue: EditAndAddViewModel(direction: direction, transaction: transaction))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                List {
                    Section {
                        categorySection
                        amountSection
                        
                        HStack {
                            Text(Constants.date)
                            Spacer()
                            DatePicker("", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                                .background(Color.lightMain)
                                .labelsHidden()
                                .cornerRadius(Constants.cornerRadius)
                                .background(Color.lightMain)
                                .labelsHidden()
                                .cornerRadius(Constants.cornerRadius)
                        }
                        HStack {
                            Text(Constants.time)
                            Spacer()
                            DatePicker("", selection: $viewModel.time, displayedComponents: .hourAndMinute)
                                .background(Color.lightMain)
                                .labelsHidden()
                                .cornerRadius(Constants.cornerRadius)
                        }
                        TextField(Constants.comments, text: $viewModel.description)
                    }
                    
                    if viewModel.isEditing {
                        Section {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteTransaction()
                                    dismiss()
                                }
                            } label: {
                                Text(viewModel.direction == .income ? Constants.deleteIncome : Constants.deleteOutcome)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Constants.cancel) { dismiss() }
                        .tint(.button)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? Constants.saveButtonTitle : Constants.createButtonTitle) {
                        Task {
                            if viewModel.validateInputs() {
                                await viewModel.saveTransaction()
                                dismiss()
                            }
                        }
                    }
                    .tint(.button)
                }
            }
            .alert(Constants.saveAlert, isPresented: $viewModel.showValidationAlert) {
                Button(Constants.alertButton, role: .cancel) { }
            }
            .navigationTitle(viewModel.direction == .income ? Constants.income : Constants.outcome)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var categorySection: some View {
        HStack {
            Text(Constants.category)
            Spacer()
            Text(viewModel.seletedCategory?.name ?? Constants.notSelected)
                .onTapGesture { showCategoryPicker = true }
            Image(systemName: "chevron.right")
                .foregroundColor(.lightGray)
        }
        .confirmationDialog(Constants.category, isPresented: $showCategoryPicker) {
            ForEach(viewModel.categories) { category in
                Button {
                    viewModel.seletedCategory = category
                } label: {
                    Text(category.name)
                        .foregroundColor(.button)
                }
            }
        }
    }
    
    private var amountSection: some View {
        HStack {
            Text(Constants.amount)
            Spacer()
            TextField(Constants.amountDigitZero, text: $viewModel.amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($isAmountFieldFocused)
                .foregroundColor(.lightGray)
                .onChange(of: viewModel.amount) { newValue in
                    viewModel.amount = viewModel.filterAmountInput(newValue)
                }
        }
    }
}
