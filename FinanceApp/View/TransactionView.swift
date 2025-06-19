//
//  TransactionView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

struct TransactionView: View {
    var income: Direction = .outcome
    var body: some View {
        VStack {
            HStack  {
                Spacer()
                
                Button {
                    print("clock")
                } label: {
                    Image(systemName: "clock")
                        .background(.clock)
                }
            }
        }
    }
}
