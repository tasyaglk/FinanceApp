//
//  StartView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 24.07.2025.
//

import SwiftUI
import LottieAnimation

struct StartView: View {
    @State private var isFinished = false
    
    var body: some View {
        if isFinished {
            TabBarView()
        } else {
            LottieView(animationName: "animation") {
                isFinished = true
            }
            .ignoresSafeArea()
            .background(Color.white)
        }
    }
}
