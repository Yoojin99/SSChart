//
//  GaugeChart.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/17.
//

import Foundation
import UIKit

// FIXME: almost same as DoughnutChart. Consider adding protocol.

public class GaugeChart: UIView, Chart {

    // MARK: public
    public var items: [GaugeChartItem] = [
        GaugeChartItem(value: 55, color: .systemGray),
        GaugeChartItem(value: 45, color: .systemGray2),
        GaugeChartItem(value: 35, color: .systemGray3)

    ] {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - private
    private var contentView = UIView()
    private var gaugeLayer = CAShapeLayer()
    
    // MARK: user custom
    /// width of the gauge line
    private let gaugeWidth: CGFloat
    /// ratio of chart width to outer circle radius
    private let outerCircleRadiusRatio: CGFloat
    /// ratio of chart width to inner circle radius
    private let innerCircleRadiusRatio: CGFloat
    private let animationDuration: Double
    /// Bool indicating pause animation at the beginning.
    let isAnimationPaused: Bool
    
    // MARK: calculated
    private var outerCircleRadius: CGFloat = 0
    private var innerCircleRadius: CGFloat = 0
    private var gaugeCenterRadius: CGFloat = 0
    
    private var didAnimation = false
    
    /// percenatge of prefix sum
    private var percentages: [ChartItemValuePercentage] = []
    
    // MARK: - init
    /// - Parameters:
    ///   - frame: frame of chart
    ///   - gaugeWidth: width of gauge line. Default 15
    ///   - outerCircleRadiusRatio: Ratio of chart width to outer circle radius. Default 2
    ///   - innerCircleRadiusRatio: Ratio of chart width to innder circle radius. Default 6
    ///   - animationDuration: Default 1.0
    ///   - isAnimationPaused: Pause animation at the beginning. Default false.
    public init(frame: CGRect, gaugeWidth: CGFloat = 15, outerCircleRadiusRatio: CGFloat = 2, innerCircleRadiusRatio: CGFloat = 6, animationDuration: Double = 1.0, isAnimationPaused: Bool = false) {
        self.gaugeWidth = gaugeWidth
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
extension GaugeChart {
    public func resumeAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let mask = self.gaugeLayer.mask,
                  !self.didAnimation else { return }
            
            if self.didAnimation { return }

            self.resumeAnimation(layer: mask, delay: 0)
            
            self.didAnimation = true
        }
    }
}

// MARK: - private
extension GaugeChart {
    func reset() {
        contentView.removeFromSuperview()
        contentView = UIView(frame: bounds)
        addSubview(contentView)
        
        gaugeLayer = CAShapeLayer(layer: layer)
        contentView.layer.addSublayer(gaugeLayer)
        
        percentages.removeAll()
        
        didAnimation = false
    }
}

// MARK: - data
extension GaugeChart {
    func calculateChartData() {
        calculateSizeProperties()
        calculatePercentages()
    }
    
    private func calculateSizeProperties() {
        self.outerCircleRadius = frame.size.width / outerCircleRadiusRatio
        self.innerCircleRadius = frame.size.width / innerCircleRadiusRatio
        self.gaugeCenterRadius = (outerCircleRadius + innerCircleRadius) / 2
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
extension GaugeChart {
    func drawChart() {
        drawPieces()
        maskChart()
    }
    
    private func drawPieces() {
        // draw from behind
        for (item, percentage) in zip(items, percentages).reversed() {
            let pieceOfPieLayer = createCircleLayer(radius: gaugeCenterRadius, startPercentage: percentage.start, endPercentage: percentage.end, borderWidth: gaugeWidth, color: item.color)
            gaugeLayer.addSublayer(pieceOfPieLayer)
        }
    }
    
    private func maskChart() {
        let maskLayer = createCircleLayer(radius: gaugeCenterRadius, startPercentage: 0, endPercentage: 1, borderWidth: gaugeWidth, color: UIColor.black)
        gaugeLayer.mask = maskLayer
    }
}
    
// MARK: - animation
extension GaugeChart {
    func addAnimation() {
        let circleAnimation = ChartAnimationFactory.createAnimation(type: .strokeEnd, duration: animationDuration)
        gaugeLayer.mask?.add(circleAnimation, forKey: "circleAnimation")
    }
    
    func pauseAnimation() {
        guard let mask = gaugeLayer.mask else {
            return
        }
        
        pauseAnimation(layer: mask)
    }
}

extension GaugeChart {
    private func createCircleLayer(radius: CGFloat, startPercentage: CGFloat, endPercentage: CGFloat, borderWidth: CGFloat, color: UIColor) -> CAShapeLayer {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(CGFloat)(Double.pi), endAngle: 0, clockwise: true)
        
        let circle = CAShapeLayer(layer: layer)
        circle.strokeStart = startPercentage
        circle.strokeEnd = endPercentage
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = color.cgColor
        circle.lineWidth = borderWidth
        circle.path = path.cgPath
        circle.lineCap = .round
        
        return circle
    }
}
