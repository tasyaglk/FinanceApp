//
//  StartView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 24.07.2025.
//

import SwiftUI

struct StartView: View {
    @State private var isFinished = false

    var body: some View {
        Group {
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
}
