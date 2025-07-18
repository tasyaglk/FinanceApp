//
//  BankAccountView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 27.06.2025.
//

import SwiftUI

struct BankAccountView: View {
    @StateObject private var viewModel = BankAccountViewModel()
    @State private var showCurrencyPicker = false
    @State private var editingBalanceText: String = ""
    @FocusState private var isBalanceFieldFocused: Bool
    @State private var isSpoilerOn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    List {
                        Section {
                            balanceView
                        }
                        .listRowBackground(viewModel.isEditing ? .white : Color.main)
                        
                        Section {
                            currencySection
                        }
                        .listRowBackground(viewModel.isEditing ? .white : Color.lightMain)
                    }
                    .listSectionSpacing(16)
                    
                    Spacer()
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
            .alert(Constants.alertTitle, isPresented: $viewModel.showInvalidBalanceAlert) {
                Button(Constants.alertButton, role: .cancel) { }
            } message: {
                Text(Constants.alertMessage)
            }
            .alert("ошибка", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("ок", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "оаоаоа а что говорить...")
            }
            .scrollDismissesKeyboard(.immediately)
            .refreshable {
                await viewModel.loadBankAccountInfo()
            }
            .task {
                await viewModel.loadBankAccountInfo()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.isEditing {
                            Task {
                                await viewModel.saveChanges(newBalanceText: editingBalanceText)
                            }
                        } else {
                            viewModel.isEditing = true
                            editingBalanceText = "\(viewModel.bankAccountInfo?.balance ?? 0)"
                        }
                    }) {
                        Text(viewModel.isEditing ? Constants.saveButtonTitle : Constants.editButtonTitle)
                            .tint(.button)
                            .font(.system(size: 17))
                    }
                }
            }
            .navigationTitle(Constants.myBankAccout)
            .navigationBarBackButtonHidden(true)
        }
        .tint(.button)
    }
    
    private var balanceView: some View {
        HStack {
            Text(Constants.moneyEmoji)
            Text(Constants.balance)
            Spacer()
            if viewModel.isEditing {
                TextField(
                    "",
                    text: $editingBalanceText,
                    onCommit: {}
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($isBalanceFieldFocused)
                .onAppear {
                    editingBalanceText = "\(viewModel.bankAccountInfo?.balance ?? 0)"
                    isBalanceFieldFocused = true
                }
                .foregroundColor(.lightGray)
            } else {
                Text("\(viewModel.bankAccountInfo?.balance ?? 0)")
                    .foregroundColor(viewModel.isEditing ? Color.lightGray : .black)
                    .spoiler(isOn: $isSpoilerOn)
                    .onShake {
                        isSpoilerOn.toggle()
                    }
            }
        }
    }
    
    private var currencySection: some View {
        HStack {
            Text(Constants.currency)
            Spacer()
            Text(viewModel.bankAccountInfo?.currency ?? CurrencyTypes.rub.symbol)
                .onTapGesture {
                    if viewModel.isEditing {
                        showCurrencyPicker = true
                    }
                }
                .foregroundColor(viewModel.isEditing ? Color.lightGray : .black)
            if viewModel.isEditing {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.lightGray)
            }
        }
        .confirmationDialog(Constants.currency, isPresented: $showCurrencyPicker, titleVisibility: .visible) {
            ForEach(CurrencyTypes.allCases, id: \.self) { currency in
                Button {
                    Task {
                        await viewModel.updateCurrencyInfo(currency.symbol)
                    }
                } label: {
                    Text(currency.name + " " + currency.symbol)
                        .foregroundColor(.button)
                }
            }
        }
    }
}
