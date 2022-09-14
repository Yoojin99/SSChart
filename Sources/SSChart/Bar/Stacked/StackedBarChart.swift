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
    private var percentages: [ChartItemValuePercentage] = []
    private var bars: [UIView] = []
    
    private let animationDelay: Double = 0.3
    private var didAnimation: Bool = false
    private var maxBarWidth: CGFloat = 0
    
    // MARK: user custom
    private let itemSpacing: Double
    private let itemCornerRadius: Double
    private let showPercentage: Bool
    private let percentageLabelFont: UIFont
    private let percentageLabelTextColor: UIColor
    private let animationDuration: Double
    private let barMoveUpSpace: Double
    private let isAnimationPaused: Bool
    
    // MARK: - init
    /// - Parameters:
    ///   - frame: frame of chart
    ///   - itemSpacing: space between item(bar). Default 0.0
    ///   - itemCornerRadius: corner radius of item. Default 0.0
    ///   - showPercentage: Bool determines to show percentage label. Default true
    ///   - percentageLabelFont: font of percentage label. Default systemfont of size 12
    ///   - percentageLabelTextColor: text color of percentage label. Default white
    ///   - animationDuration: animation duartion. Default 0.8
    ///   - barMoveUpSpace: space that bar moves up during animation. Default 20
    ///   - isAnimationPaused: bool indicates to pause animation at the beginning. Default false
    public init(frame: CGRect, itemSpacing: Double = 0.0, itemCornerRadius: Double = 0.0, showPercentage: Bool = true, percentageLabelFont: UIFont = UIFont.systemFont(ofSize: 12), percentageLabelTextColor: UIColor = UIColor.white, animationDuration: Double = 0.5, barMoveUpSpace: Double = 0, isAnimationPaused: Bool = false) {
        self.itemSpacing = itemSpacing
        self.itemCornerRadius = itemCornerRadius
        self.showPercentage = showPercentage
        self.percentageLabelFont = percentageLabelFont
        self.percentageLabelTextColor = percentageLabelTextColor
        self.animationDuration = animationDuration
        self.barMoveUpSpace = barMoveUpSpace
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
        
        if isAnimationPaused {
            pauseAnimation()
        }
    }
}

// MARK: - public
extension StackedBarChart {
    public func resumeAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.didAnimation else { return }
            
            for (index, bar) in self.bars.enumerated() {
                self.resumeAnimation(layer: bar.layer, delay: Double(index) * self.animationDelay)
            }
            
            self.didAnimation = true
        }
    }
}

// MARK: - private
extension StackedBarChart {
    func reset() {
        bars.removeAll()
        percentages.removeAll()

        subviews.forEach{ $0.removeFromSuperview() }
        
        didAnimation = false
    }
}

// MARK: - data
extension StackedBarChart {
    func calculateChartData() {
        let totalValue = items.reduce(CGFloat(0)) { currentSum, item in
            assert(item.value > 0, "[SSChart] StackedBarChartItem should have positive value.")
            return currentSum + item.value
        }
        
        maxBarWidth = bounds.width - (Double((items.count-1)) * itemSpacing)
        
        var currentTotalValue: CGFloat = 0
        
        items.forEach { item in
            percentages.append(ChartItemValuePercentage(start: (currentTotalValue / totalValue), end: (currentTotalValue + item.value) / totalValue))
            currentTotalValue += item.value
        }
    }
}

// MARK: - draw
extension StackedBarChart {
    func drawChart() {
        if items.isEmpty {
            let bar = createBar(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), color: .systemGray)
            addSubview(bar)
            bars.append(bar)
            
            if showPercentage {
                let label = createPercentageLabel(percentage: ChartItemValuePercentage(start: 0, end: 0))
                label.center = CGPoint(x: bar.bounds.width/2, y: bar.bounds.height/2)
                bar.addSubview(label)
            }
            return
        }
        
        for (index, (item, percentage)) in zip(items, percentages).enumerated() {
            drawBars(index, item, percentage, showPercentage: showPercentage)
        }
    }
    
    private func drawBars(_ index: Int, _ item: StackedBarChartItem, _ percentage: ChartItemValuePercentage, showPercentage: Bool) {
        
        let bar = createBar(frame: CGRect(x: (maxBarWidth * percentage.start) + (Double(index) * itemSpacing), y: barMoveUpSpace, width: maxBarWidth * (percentage.end - percentage.start), height: frame.height), color: item.color)
        addSubview(bar)
        bars.append(bar)
        
        if showPercentage {
            let label = createPercentageLabel(percentage: percentage)
            label.center = CGPoint(x: bar.bounds.width/2, y: bar.bounds.height/2)
            
            bar.addSubview(label)
        }
    }
    
    private func createBar(frame: CGRect, color: UIColor) -> UIView {
        let bar = UIView(frame: frame)
        bar.backgroundColor = color
        bar.alpha = 0
        bar.layer.cornerRadius = itemCornerRadius
        
        return bar
    }
    
    private func createPercentageLabel(percentage: ChartItemValuePercentage) -> UILabel {
        let label = UILabel()
        label.font = percentageLabelFont
        label.textColor = percentageLabelTextColor
        
        let calculatedPercentage = Int((percentage.end - percentage.start) * 100)
        label.text = "\(calculatedPercentage)%"
        label.sizeToFit()
        
        return label
    }
}

// MARK: - animation
extension StackedBarChart {
    func addAnimation() {
        for (index, bar) in bars.enumerated() {
            bar.layer.add(createAnimationGroup(delay: Double(index) * animationDelay), forKey: "barAnimations")
        }
    }
    
    func pauseAnimation() {
        for bar in bars {
            pauseAnimation(layer: bar.layer)
        }
    }
        
    private func createAnimationGroup(delay: Double) -> CAAnimationGroup {
        return ChartAnimationFactory.createAnimationGroup(types: [.moveVertical(value: -barMoveUpSpace), .fadeIn], duration: animationDuration, beginTimeDelay: delay, timingFunctionName: .easeInEaseOut, isRemovedOnCompletion: false, fillMode: .forwards)
    }
}
