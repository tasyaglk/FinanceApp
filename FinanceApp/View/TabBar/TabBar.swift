//
//  TabBarView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 20.06.2025.
//

import SwiftUI

struct TabBarView: View {
    
    init() {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor.white
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    
    var body: some View {
        TabView {
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Image("outcomeImage")
                        .renderingMode(.template)
                    Text("Расходы")
                        .font(.system(size: 10))
                }
            
            TransactionsListView(direction: .income)
                .tabItem {
                    Image("incomeImage")
                        .renderingMode(.template)
                    Text("Доходы")
                        .font(.system(size: 10))
                }
            
            Text("Счет")
                .tabItem {
                    Image("scoreImage")
                        .renderingMode(.template)
                    Text("Счет")
                        .font(.system(size: 10))
                }
            
            Text("Статьи")
                .tabItem {
                    Image("articlesImage")
                        .renderingMode(.template)
                    Text("Статьи")
                        .font(.system(size: 10))
                }
            
            Text("Настройки")
                .tabItem {
                    Image("settingsImage")
                        .renderingMode(.template)
                    Text("Настройки")
                        .font(.system(size: 10))
                }
        }
        .tint(.main)
    }
}
