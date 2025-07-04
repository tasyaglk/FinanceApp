//
//  EmitterView.swift
//  FinanceApp
//
//  Created by Тася Галкина on 28.06.2025.
//

import SwiftUI

final class EmitterView: UIView {

    override class var layerClass: AnyClass {
        CAEmitterLayer.self
    }

    override var layer: CAEmitterLayer {
        super.layer as! CAEmitterLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.emitterPosition = .init(x: bounds.size.width / 2,
                                      y: bounds.size.height / 2)
        layer.emitterSize = bounds.size
    }
}
