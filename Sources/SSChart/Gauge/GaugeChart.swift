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
    // 유효하지 않은 값 / 새로 데이터 안 들어올 때 기본 회색 차트 노출하게 해야 함
    public var items: [GaugeChartItem] = [
        GaugeChartItem(value: 55, color: .black),
        GaugeChartItem(value: 45, color: .systemGray)
    ] {
        didSet {
            reload()
        }
    }
    
    private var contentView = UIView()
    private var gaugeLayer = CAShapeLayer()
    
    // MARK: - user custom
    private let animationDuration: Double
    private let gaugeWidth: CGFloat
    
    // MARK: - calculated
    private let outerCircleRadius: CGFloat
    private let innerCircleRadius: CGFloat
    private let gaugeCenterRadius: CGFloat
    
    private var didAnimation = false
    
    /// percenatge of prefix sum
    private var percentages: [ChartItemValuePercentage] = []
    
    // MARK: - init
    /// - Parameters:
    ///   - frame: frame of chart
    ///   - gaugeWidth: width of gauge line. Default 15
    ///   - outerCircleRadiusRatio: Ratio of width to outer circle radius. Default 2
    ///   - innerCircleRadiusRatio: Ratio of width to innder circle radius. Default 6
    ///   - animationDuration: Default 1.0
    public init(frame: CGRect, gaugeWidth: CGFloat = 15, outerCircleRadiusRatio: CGFloat = 2, innerCircleRadiusRatio: CGFloat = 6, animationDuration: Double = 1.0) {
        self.outerCircleRadius = frame.size.width / outerCircleRadiusRatio
        self.innerCircleRadius = frame.size.width / innerCircleRadiusRatio
        self.gaugeCenterRadius = (outerCircleRadius + innerCircleRadius) / 2
        self.gaugeWidth = gaugeWidth
        self.animationDuration = animationDuration
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - public
extension GaugeChart {
    public func pauseAnimation() {
        guard let mask = gaugeLayer.mask else {
            return
        }
        
        pauseAnimation(layer: mask)
    }
    
    public func resumeAnimation() {
        // ???: is it right to use async, put whole block in async?
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
    private func reload() {
        reset()
        calculateChartData()
        drawChart()
        addAnimation()
    }
    
    // MARK: - reset
    private func reset() {
        contentView.removeFromSuperview()
        contentView = UIView(frame: bounds)
        addSubview(contentView)
        
        gaugeLayer = CAShapeLayer(layer: layer)
        contentView.layer.addSublayer(gaugeLayer)
        
        didAnimation = false
    }
}


extension GaugeChart {
    // MARK: - data
    private func calculateChartData() {
        calculatePercentages()
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
    private func drawChart() {
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
    private func addAnimation() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = animationDuration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        gaugeLayer.mask?.add(animation, forKey: "circleAnimation")
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
