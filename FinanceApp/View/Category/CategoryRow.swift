//
//  CategoryRow.swift
//  FinanceApp
//
//  Created by Тася Галкина on 04.07.2025.
//

import SwiftUI

struct CategoryRow: View {
    let category: Category?
    
    var body: some View {
        HStack {
            Text("\(category?.emoji ?? "?")")
                .font(.system(size: 12))
                .frame(width: 22, height: 22)
                .background(.lightMain)
                .clipShape(Circle())
            
            VStack {
                Text(category?.name ?? "undefined")
                    .font(.system(size: 17))
            }
            
            Spacer()
            
        }
    }
}

