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
                
            }
            .task {
                await viewModel.loadBankAccountInfo()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isEditing.toggle()
                        if viewModel.isEditing {
                            print("edit mode activated")
                        } else {
                            viewModel.saveChanges()
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
    
    private var balanceView:some View {
        HStack {
            Text(Constants.moneyEmoji)
            
            Text(Constants.balance)
            
            Spacer()
            
            Text("\(viewModel.bankAccountInfo?.balance ?? 0)")
                .foregroundColor(viewModel.isEditing ? Color.lightGray : .black)
        }
    }
    
    private var currencySection: some View {
        HStack {
            Text(Constants.currency)
            
            Spacer()
            
            Text(viewModel.bankAccountInfo?.currency ?? "$")
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
        .confirmationDialog("Валюта", isPresented: $showCurrencyPicker, titleVisibility: .visible) {
            ForEach(CurrencyTypes.allCases, id: \.self) { currency in
                Button {
                    Task {
                        await viewModel.updateBankAccountInfo("\(viewModel.bankAccountInfo?.balance ?? 0)", currency.symbol)
                    }
                } label: {
                    Text(currency.name + " " + currency.symbol)
                        .foregroundColor(.button)
                }
            }
        }
        
    }
}

//#Preview {
//    BankAccountView()
//}
