//
//  AnalysisViewControllerRepresentable.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import SwiftUI
import UIKit

struct AnalysisViewControllerRepresentable: UIViewControllerRepresentable {
    
    let direction: Direction
    let startDate: Date
    let endDate: Date
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        return AnalysisViewController(
            direction: direction,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
    }
}
