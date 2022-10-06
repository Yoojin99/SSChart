//
//  StackedBarChart.swift
//  
//
//  Created by YJ on 2022/09/02.
//

import Foundation
import UIKit

public class StackedBarChart: UIView, Chart {
    
    // MARK: - public
    public var items: [StackedBarChartItem] = [] {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - private
    private var contentView: UIView = UIView()
    private var barLayer: CAShapeLayer = CAShapeLayer()
    private var maskLayer: CAShapeLayer = CAShapeLayer()
    
    private var percentages: [ChartItemValuePercentage] = []
    
    private var didAnimation: Bool = false
    
    // MARK: user custom
    private let barCornerRadius: CGFloat
    private let defaultColor: UIColor
    private let animationDuration: Double
    let isAnimationPaused: Bool

    // MARK: - init
    /// - Parameters:
    ///   - frame: frame of chart
    ///   - barCornerRadius: cornerRaidus of stacked bar chart. Default 10
    ///   - animationDuration: animation duartion. Default 1
    ///   - isAnimationPaused: bool indicates to pause animation at the beginning. Default false
    public init(frame: CGRect, barCornerRadius: CGFloat = 10, defaultColor: UIColor, animationDuration: Double = 1, isAnimationPaused: Bool = false) {
        self.barCornerRadius = barCornerRadius
        self.defaultColor = defaultColor
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
extension StackedBarChart {
    public func resumeAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let mask = self.barLayer.mask,
                  !self.didAnimation else { return }

            self.resumeAnimation(layer: mask, delay: 0)

            self.didAnimation = true
        }
    }
}

// MARK: - private
extension StackedBarChart {
    func reset() {
        percentages.removeAll()
        
        contentView.removeFromSuperview()
        contentView = UIView(frame: bounds)
        contentView.layer.cornerRadius = barCornerRadius
        contentView.backgroundColor = .systemGray5
        contentView.clipsToBounds = true
        addSubview(contentView)
        
        barLayer = CAShapeLayer(layer: layer)
        contentView.layer.addSublayer(barLayer)
                
        didAnimation = false
    }
}

// MARK: - data
extension StackedBarChart {
    func calculateChartData() {
        let totalValue = items.reduce(CGFloat(0)) { currentSum, item in
            assert(item.value >= 0, "[SSChart] StackedBarChartItem can't have negative value.")
            return currentSum + item.value
        }
        
        var prefixSum: CGFloat = 0
        
        items.forEach { item in
            percentages.append(ChartItemValuePercentage(start: prefixSum / totalValue, end: (prefixSum + item.value) / totalValue))
            prefixSum += item.value
        }
    }
}

// MARK: - draw
extension StackedBarChart {
    func drawChart() {
        drawBars()
        maskChart()
    }
    
    func drawBars() {
        for (item, percentage) in zip(items, percentages) {
            let pieceOfBarLayer =
            createBarLayer(with: percentage, color: item.color)
            barLayer.addSublayer(pieceOfBarLayer)
        }
    }
    
    private func createBarLayer(with percentage: ChartItemValuePercentage, color: UIColor) -> CAShapeLayer {
        let barXPos = percentage.start * bounds.width
        let barWidth = (percentage.end - percentage.start) * bounds.width
        let bar = CAShapeLayer(layer: layer)
        bar.path = UIBezierPath(roundedRect: CGRect(x: barXPos, y: 0, width: barWidth, height: bounds.height), cornerRadius: 0).cgPath
        bar.fillColor = color.cgColor
        
        return bar
    }
    
    private func maskChart() {
        maskLayer = createBarLayer(with: ChartItemValuePercentage(start: 0, end: 0), color: UIColor.black
        )

        barLayer.mask = maskLayer
    }
}

// MARK: - animation
extension StackedBarChart {
    func addAnimation() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = maskLayer.path
        animation.toValue = UIBezierPath(rect: bounds).cgPath
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        maskLayer.add(animation, forKey: nil)
    }
   
   func pauseAnimation() {
       guard let mask = barLayer.mask else {
           return
       }

       pauseAnimation(layer: mask)
   }
}
