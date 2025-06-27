//
//  BankAccountView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 27.06.2025.
//

import SwiftUI

struct BankAccountView: View {
    @StateObject private var viewModel = BankAccountViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    List {
                        Section {
                            HStack {
                                Text(Constants.moneyEmoji)
                                
                                Text(Constants.balance)
                                
                                Spacer()
                                
                                Text("\(viewModel.bankAccountInfo?.balance ?? 0)")
                            }
                        }
                        .listRowBackground(Color.main)
                        
                        Section {
                            HStack {
                                Text(Constants.currency)
                                
                                Spacer()
                                
                                Text(viewModel.bankAccountInfo?.currency ?? "$")
                            }
                        }
                        .listRowBackground(Color.lightMain)
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
                        print("hui")
                    }) {
                        Text(Constants.editButtonTitle)
                            .tint(.button)
                            .font(.system(size: 17))
                    }
                }
            }
            .navigationTitle(Constants.myBankAccout)
            .navigationBarBackButtonHidden(true)
        }
    }
}

//#Preview {
//    BankAccountView()
//}
