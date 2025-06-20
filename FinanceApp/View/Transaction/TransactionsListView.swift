//
//  TransactionsListView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @StateObject private var viewModel: TransactionViewModel
    
    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: TransactionViewModel(direction: direction))
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack {
                    HStack  {
                        Spacer()
                        
                        Button {
                            print("clock")
                        } label: {
                            Image(systemName: "clock")
                                .tint(.clock)
                        }
                    }
                    
                    HStack {
                        Text(viewModel.direction == .income ? Constants.incomeTitle : Constants.outcomeTitle)
                            .font(.system(size: 34, weight: .bold))
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                
                List {
                    Section {
                        TotalCellView(title: Constants.total, total: viewModel.totalAmount)
                    }
                    
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
                                    .frame(width: 56, height: 56)
                                    .foregroundColor(.main)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                            .padding(.bottom, 16)
                            .padding(.trailing, 16)
                        }
                    }
                }
            )
        }
    }
}
