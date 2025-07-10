//
//  TotalCellView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

struct TotalCellView: View {
    let title: String
    let total: Decimal
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
            
            Spacer()
            
            Text("\(total) \(Constants.russianCurrency)")
                .font(.system(size: 17))
            
        }
    }
}
