//
//  DoughnutChart.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/17.
//

import Foundation
import UIKit

public class DoughnutChart: UIView {
    
    // MARK: public
    public var items: [DoughnutChartItem] = [
        DoughnutChartItem(value: 55, color: .systemGray),
        DoughnutChartItem(value: 45, color: .systemGray2)
    ] {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - private
    private var contentView = UIView()
    private var doughnutLayer = CAShapeLayer()
    
    // MARK: user custom
    /// ratio of chart width to outer circle radius
    private let outerCircleRadiusRatio: CGFloat
    /// ratio of chart width to inner circle radius
    private let innerCircleRadiusRatio: CGFloat
    private let animationDuration: Double
    /// Bool indicating pause animation at the beginning.
    private let isAnimationPaused: Bool
    
    // MARK: calculated
    private var outerCircleRadius: CGFloat          = 0
    private var innerCircleRadius: CGFloat          = 0
    private var doughnutCenterRadius: CGFloat       = 0
    private var doughnutWidth: CGFloat              = 0
    
    private var didAnimation = false
    
    /// percenatge of prefix sum
    private var percentages: [ChartItemValuePercentage] = []
    
    // TODO: draw title for each pieces
    
    // MARK: - init
    /// - Parameters:
    ///   - frame: frame of chart
    ///   - outerCircleRadiusRatio: Ratio of width to outer circle radius. Default 2
    ///   - innerCircleRadiusRatio: Ratio of width to innder circle radius. Default 6
    ///   - animationDuration: Default 1.0
    ///   - isAnimationPaused: Pause animation at the beginning. Default false.
    public init(frame: CGRect, outerCircleRadiusRatio: CGFloat = 2, innerCircleRadiusRatio: CGFloat = 6, animationDuration: Double = 1.0, isAnimationPaused: Bool = false) {
        self.outerCircleRadiusRatio = outerCircleRadiusRatio
        self.innerCircleRadiusRatio = innerCircleRadiusRatio
        self.animationDuration = animationDuration
        self.isAnimationPaused = isAnimationPaused
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        reload()
    }
}

// MARK: - public
// MARK: Chart
extension DoughnutChart: Chart {
    public func resumeAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let mask = self.doughnutLayer.mask,
                  !self.didAnimation else { return }
            
            if self.didAnimation { return }

            self.resumeAnimation(layer: mask, delay: 0)
            
            self.didAnimation = true
        }
    }
}

// MARK: - private
extension DoughnutChart {
    func reload() {
        reset()
        calculateChartData()
        drawChart()
        addAnimation()
        
        if isAnimationPaused {
            pauseAnimation()
        }
    }
    
    func reset() {
        percentages.removeAll()
        
        contentView.removeFromSuperview()
        contentView = UIView(frame: bounds)
        addSubview(contentView)
        
        doughnutLayer = CAShapeLayer(layer: layer)
        contentView.layer.addSublayer(doughnutLayer)
        
        didAnimation = false
    }
}

// MARK: - data
extension DoughnutChart {
    func calculateChartData() {
        calculateSizeProperties()
        calculatePercentages()
    }
    
    private func calculateSizeProperties() {
        self.outerCircleRadius = frame.size.width / outerCircleRadiusRatio
        self.innerCircleRadius = frame.size.width / innerCircleRadiusRatio
        self.doughnutCenterRadius = (outerCircleRadius + innerCircleRadius) / 2
        self.doughnutWidth = outerCircleRadius - innerCircleRadius
    }
    
    private func calculatePercentages() {
        let totalValue = items.reduce(0) { partialResult, item in
            partialResult + item.value
        }
        
        // TODO: - show default chart if total value is 0
        assert(totalValue != 0, "total value of items should not be 0")
        
        var currentTotalValue: CGFloat = 0
        
        items.forEach { item in
            percentages.append(ChartItemValuePercentage(start: (currentTotalValue / totalValue), end: (currentTotalValue + item.value) / totalValue))
            currentTotalValue += item.value
        }
    }
}

// MARK: - draw
extension DoughnutChart {
    func drawChart() {
        drawPieces()
        maskChart()
    }
    
    private func drawPieces() {
        for (item, percentage) in zip(items, percentages) {
            let pieceOfPieLayer = createCircleLayer(radius: doughnutCenterRadius, startPercentage: percentage.start, endPercentage: percentage.end, borderWidth: doughnutWidth, color: item.color)
            doughnutLayer.addSublayer(pieceOfPieLayer)
        }
    }
    
    private func maskChart() {
        let maskLayer = createCircleLayer(radius: doughnutCenterRadius, startPercentage: 0, endPercentage: 1, borderWidth: doughnutWidth, color: UIColor.black)
        doughnutLayer.mask = maskLayer
    }
}

// MARK: - animation
extension DoughnutChart {
     func addAnimation() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = animationDuration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        doughnutLayer.mask?.add(animation, forKey: "circleAnimation")
    }
    
    func pauseAnimation() {
        guard let mask = doughnutLayer.mask else {
            return
        }
        
        pauseAnimation(layer: mask)
    }
}

extension DoughnutChart {
    private func createCircleLayer(radius: CGFloat, startPercentage: CGFloat, endPercentage: CGFloat, borderWidth: CGFloat, color: UIColor) -> CAShapeLayer {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(CGFloat)(Double.pi/2), endAngle: CGFloat(Double.pi/2) * 3, clockwise: true)

        
        let circle = CAShapeLayer(layer: layer)
        circle.strokeStart = startPercentage
        circle.strokeEnd = endPercentage
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = color.cgColor
        circle.lineWidth = borderWidth
        circle.path = path.cgPath
        return circle
    }
}
