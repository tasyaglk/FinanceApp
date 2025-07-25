//
//  PieChart.swift
//  Utilities
//
//  Created by Тася Галкина on 25.07.2025.
//

import UIKit

public struct Entity {
    public let value: Decimal
    public let label: String

    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

public class PieChartView: UIView {

    public var entities: [Entity] = [] {
        didSet {
            prepareSlices()
            startAnimation()
        }
    }

    private let maxVisibleSegments = 5
    private let segmentColors: [UIColor] = [
        UIColor.systemYellow,
        UIColor.systemGreen,
        UIColor.systemBlue,
        UIColor.systemPink,
        UIColor.systemPurple,
        UIColor.systemGray
    ]

    private var slices: [(value: CGFloat, label: String, color: UIColor)] = []
    private var animationProgress: CGFloat = 0.0
    private var displayLink: CADisplayLink?
    private var isAnimatingOut = true


    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareSlices() {
        let total = entities.reduce(Decimal(0)) { $0 + $1.value }
        guard total > 0 else {
            slices = []
            return
        }

        slices = entities.enumerated().map { index, entity in
            let percentage = CGFloat((entity.value / total as NSDecimalNumber).doubleValue)
            let color = segmentColors.indices.contains(index) ? segmentColors[index] : UIColor.systemGray
            return (value: percentage, label: entity.label, color: color)
        }
    }

    public override func draw(_ rect: CGRect) {
        guard !slices.isEmpty else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) * 0.4
        let ringThickness: CGFloat = 8.0

        context?.translateBy(x: center.x, y: center.y)
        context?.rotate(by: .pi * animationProgress)
        context?.translateBy(x: -center.x, y: -center.y)

        var startAngle = -CGFloat.pi / 2

        for slice in slices {
            let endAngle = startAngle + 2 * .pi * slice.value

            let path = UIBezierPath()
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addArc(withCenter: center, radius: radius - ringThickness, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()

            slice.color.withAlphaComponent(fadeAlpha()).setFill()
            path.fill()

            startAngle = endAngle
        }

        context?.restoreGState()

        drawLegend(center: center, radius: radius)
    }

    private func drawLegend(center: CGPoint, radius: CGFloat) {
        let circleRadius: CGFloat = 6
        let spacing: CGFloat = 18
        let textFont = UIFont.systemFont(ofSize: 12)
        let attributes: [NSAttributedString.Key: Any] = [.font: textFont, .foregroundColor: UIColor.black.withAlphaComponent(fadeAlpha())]

        for (i, slice) in slices.enumerated() {
            let yOffset = CGFloat(i) * spacing - spacing * CGFloat(slices.count - 1) / 2
            let circleCenter = CGPoint(x: center.x - 40, y: center.y + yOffset)

            let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            slice.color.withAlphaComponent(fadeAlpha()).setFill()
            circlePath.fill()

            let percent = String(format: "%.2f%%", slice.value * 100)
            let text = "\(percent) \(slice.label)"
            let nsText = text as NSString
            let textPoint = CGPoint(x: circleCenter.x + 12, y: circleCenter.y - 8)
            nsText.draw(at: textPoint, withAttributes: attributes)
        }
    }

    private func startAnimation() {
        displayLink?.invalidate()
        animationProgress = 0
        isAnimatingOut = true
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc private func updateAnimation() {
        let step: CGFloat = 0.02
        animationProgress += step

        if isAnimatingOut && animationProgress >= 0.5 {
            isAnimatingOut = false
        }

        if animationProgress >= 1.0 {
            animationProgress = 1.0
            displayLink?.invalidate()
            displayLink = nil
        }

        setNeedsDisplay()
    }

    private func fadeAlpha() -> CGFloat {
        if animationProgress <= 0.5 {
            return 1 - (animationProgress * 2)
        } else {
            return (animationProgress - 0.5) * 2 
        }
    }
}
