//
//  TransactionRow.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

struct TransactionRow: View {
    let category: Category?
    let transaction: Transaction
    
    var body: some View {
        HStack {
            if category?.direction == .outcome {
                Text("\(category?.emoji ?? "?")")
                    .font(.system(size: 12))
                    .frame(width: 22, height: 22)
                    .background(.lightMain)
                    .clipShape(Circle())
            }
            
            VStack {
                Text(category?.name ?? "undefinded")
                    .font(.system(size: 17))
                
                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text("\(transaction.amount) \(Constants.russianCurrency)")
                .font(.system(size: 17))
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}
