//
//  BarChart.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/18.
//

import Foundation
import UIKit

/**
 Horizontal Bar Chart
 
 Bar chart will be drawn as below.
 
 | GroupLabel | ItemLabel | Bar | DescriptionLabel |
 
 If there is a group that has label, groupLabel will be drawn.
 If there is an item that has label, itemLabel will be drawn. The same applies to descriptionLabel.
 */
public class BarChart: UIView, Chart {
    /// cgPoints of each group for drawing
    private struct BarPoint {
        let topLeftPoint: CGPoint
        let bottomRightPoint: CGPoint
        let subPoints: [BarPoint]
        
        init(topLeftPoint: CGPoint, bottomRightPoint: CGPoint, subPoints: [BarPoint] = []) {
            self.topLeftPoint = topLeftPoint
            self.bottomRightPoint = bottomRightPoint
            self.subPoints = subPoints
        }
    }
        
    // MARK: user setup
    /// space between groups
    private let groupSpace: CGFloat
    /// space between items
    private let itemSpace: CGFloat
    private let groupLabelWidth: CGFloat
    private let itemLabelWidth: CGFloat
    private let descriptionLabelWidth: CGFloat
    private let animationDelayInterval: Double
    private let showAverageLine: Bool
    private let averageLineColor: UIColor
    
    // MARK: calculated
    private var showGroupLabel              = false
    private var showItemLabel               = false
    private var showDescriptionLabel        = false
    private var didAnimation                = false
    
    private var itemHeight: CGFloat         = 0
    private var maxBarWidth: CGFloat        = 0
    
    private var maxValue: CGFloat           = 0
    
    // MARK: average line
    private var averageLineLayer = CAShapeLayer()
    private var averageValue: CGFloat               = 0
    private var averageLineAnimationDelay: Double    = 0.0
    
    // TODO: add margins
        
    public var items: [BarChartGroupItem] = [] {
        // TODO: load default data when empty
        didSet {
            reload()
        }
    }
    
    private var groupPoints: [BarPoint] = []
    private var bars: [UIView] = []
    
    // MARK: - init
    /// - Parameters:
    ///   - frame: frame of chart
    ///   - groupSpace: space between groups. Default 10
    ///   - itemSpace: space between items. Default 3
    ///   - groupLabelWidth: width of group text label. Default 52
    ///   - itemLabelWidth: width of item text label. Default 52
    ///   - descriptionLabelWidth:width of description text label. Default 52
    ///   - animationDelayInterval : interval between animation start time for each bar. Default 0.3
    ///   - showAverageLine : Default false
    ///   - averageLineColor: color of average line. Default systemRed
    public init(frame: CGRect, groupSpace: CGFloat = 10, itemSpace: CGFloat = 3, groupLabelWidth: CGFloat = 52, itemLabelWidth: CGFloat = 52, descriptionLabelWidth: CGFloat = 52, animationDelayInterval: Double = 0.3, showAverageLine: Bool = false, averageLineColor: UIColor = UIColor.systemRed) {
        self.groupSpace = groupSpace
        self.itemSpace = itemSpace
        self.groupLabelWidth = groupLabelWidth
        self.itemLabelWidth = itemLabelWidth
        self.descriptionLabelWidth = descriptionLabelWidth
        self.animationDelayInterval = animationDelayInterval
        self.showAverageLine = showAverageLine
        self.averageLineColor = averageLineColor
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - public
extension BarChart {
    public func pauseAnimation() {
        for bar in bars {
            pauseAnimation(layer: bar.layer)
        }
        
        if showAverageLine {
            pauseAnimation(layer: averageLineLayer)
        }
    }
    
    public func resumeAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.didAnimation else { return }

            for (index, bar) in self.bars.enumerated() {
                self.resumeAnimation(layer: bar.layer, delay: Double(index) * self.animationDelayInterval)
            }
            
            if self.showAverageLine {
                self.resumeAnimation(layer: self.averageLineLayer, delay: self.averageLineAnimationDelay)
            }
            
            self.didAnimation = true
        }
    }
}

// MARK: - private
extension BarChart {
    private func reload() {
        reset()
        calculateChartData()
        drawChart()
    }
    
    private func reset() {
        subviews.forEach{ $0.removeFromSuperview() }
        // TODO: items.removeAll()
        bars.removeAll()
        
        showGroupLabel = false
        showItemLabel = false
        showDescriptionLabel = false
        didAnimation = false
    }
    
    private func calculateChartData() {
        let groupCount = items.count
        var itemCount: Int = 0
        var totalValue: CGFloat = 0
        var maxItemCountInGroup = 0
        
        for group in items {
            showGroupLabel = showGroupLabel || group.label != nil
            itemCount += group.items.count
            maxItemCountInGroup = max(maxItemCountInGroup, group.items.count)
            
            for item in group.items {
                showItemLabel = showItemLabel || item.label != nil
                showDescriptionLabel = showDescriptionLabel || item.descriptionLabel != nil
                maxValue = max(maxValue, item.value)
                totalValue += item.value
            }
        }
        
        averageValue = totalValue / CGFloat(itemCount)
        let groupSpaceCount = items.count - 1
        let itemSpaceCount = itemCount - groupCount
        let totalSpace = (groupSpace * CGFloat(groupSpaceCount)) + (itemSpace * CGFloat(itemSpaceCount))
        itemHeight = (frame.height - totalSpace) / CGFloat(itemCount)
        averageLineAnimationDelay = Double(maxItemCountInGroup-1) * animationDelayInterval + 1
        
        maxBarWidth = frame.width
        if showGroupLabel { maxBarWidth -= groupLabelWidth }
        if showItemLabel { maxBarWidth -= itemLabelWidth }
        if showDescriptionLabel { maxBarWidth -= descriptionLabelWidth }
        
        // calculate points
        var y: CGFloat = 0
        
        groupPoints = items.map({ group -> BarPoint in
            let itemPoints: [BarPoint] = group.items.enumerated().map { (itemIndex, _) in
                let itemYPos = y + CGFloat(itemIndex) * (itemHeight + itemSpace)
                return BarPoint(topLeftPoint: CGPoint(x: 0, y: itemYPos), bottomRightPoint: CGPoint(x: frame.width, y: itemYPos + itemHeight))
            }
            
            let groupHeight = CGFloat(group.items.count) * itemHeight + CGFloat(group.items.count - 1) * itemSpace
            let groupBarPoint = BarPoint(topLeftPoint: CGPoint(x: 0, y: y), bottomRightPoint: CGPoint(x: frame.width, y: y + groupHeight), subPoints: itemPoints)
            y += groupHeight + groupSpace
            return groupBarPoint
        })
    }
}

// MARK: view
extension BarChart {
    private func drawChart() {
        for (groupIndex, group) in items.enumerated() {
            drawGroup(group, at: groupPoints[groupIndex])
        }
        
        if showAverageLine {
            drawAverageLine()
        }
    }
    
    private func drawAverageLine() {
        var xPos: CGFloat = maxBarWidth * (averageValue / maxValue)
        
        if showGroupLabel { xPos += groupLabelWidth }
        if showItemLabel { xPos += itemLabelWidth }
        
        averageLineLayer = createDashLine(xPos: xPos)
        layer.addSublayer(averageLineLayer)
    }
    
    private func drawGroup(_ group: BarChartGroupItem, at point: BarPoint) {
        let groupLabelHeight = point.bottomRightPoint.y - point.topLeftPoint.y

        if showGroupLabel {
            let label = createLabel(frame: CGRect(x: point.topLeftPoint.x, y: point.topLeftPoint.y, width: groupLabelWidth, height: groupLabelHeight), labelItem: group.label!, align: .left)
            addSubview(label)
        }
        
        for (itemIndex, item) in group.items.enumerated() {
            drawItem(item, at: point.subPoints[itemIndex], index: itemIndex)
        }
    }
    
    private func drawItem(_ item: BarChartItem, at point: BarPoint, index: Int) {
        let barWidth: CGFloat = maxBarWidth * (item.value / maxValue)
        var itemLabelX: CGFloat = point.topLeftPoint.x, barX: CGFloat = point.topLeftPoint.x, descriptionLabelX: CGFloat = maxBarWidth
        
        if showGroupLabel {
            itemLabelX += groupLabelWidth
            barX += groupLabelWidth
            descriptionLabelX += groupLabelWidth
        }
        
        if showItemLabel {
            barX += itemLabelWidth
            descriptionLabelX += itemLabelWidth
            
            let label = createLabel(frame: CGRect(x: itemLabelX, y: point.topLeftPoint.y, width: itemLabelWidth, height: itemHeight), labelItem: item.label!, align: .left)
            addSubview(label)
        }
        
        let bar = createBar(frame: CGRect(x: barX, y: point.topLeftPoint.y, width: barWidth, height: itemHeight), item: item, delay: Double(index) * animationDelayInterval)
        addSubview(bar)
        bars.append(bar)
        
        if showDescriptionLabel {
            let descriptionLabel = createLabel(frame: CGRect(x: descriptionLabelX, y: point.topLeftPoint.y, width: descriptionLabelWidth, height: itemHeight), labelItem: item.descriptionLabel!, align: .right)
            addSubview(descriptionLabel)
        }
    }
}

extension BarChart {
    private func createLabel(frame: CGRect, labelItem: BarChartLabelItem, align: NSTextAlignment) -> UILabel {
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.text = labelItem.text
        label.textColor = labelItem.textColor
        label.font = labelItem.font
        label.textAlignment = align
        return label
    }
    
    private func createBar(frame: CGRect, item: BarChartItem, delay: Double) -> UIView {
        let view = UIView(frame: .zero)
        
        view.backgroundColor = item.color
        let growAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        growAnimation.duration = 1
        growAnimation.fromValue = 0
        growAnimation.toValue = frame.width
        growAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        growAnimation.beginTime = CACurrentMediaTime() + delay
        growAnimation.fillMode = .forwards
        growAnimation.isRemovedOnCompletion = false

        view.layer.anchorPoint = CGPoint(x: 0, y: 0)
        view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: 0, height: frame.height)
        view.layer.add(growAnimation, forKey: "growAnimation")
        
        return view
    }
    
    private func createDashLine(xPos: CGFloat) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = averageLineColor.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [3,3]
        shapeLayer.opacity = 0
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: xPos, y: 0), CGPoint(x: xPos, y: frame.height)])
        shapeLayer.path = path
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0.0
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.duration = 1.2
        fadeInAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        fadeInAnimation.fillMode = .forwards
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.beginTime = CACurrentMediaTime() + averageLineAnimationDelay
        shapeLayer.add(fadeInAnimation, forKey: "fadeIn")
        
        return shapeLayer
    }
}
