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
    
    public struct AverageLineInfo {
        let lineColor: UIColor
        let bottomSpaceAreaHeight: CGFloat
        
        public init(lineColor: UIColor, bottomSpaceAreaHeight: CGFloat = 0) {
            self.lineColor = lineColor
            self.bottomSpaceAreaHeight = bottomSpaceAreaHeight
        }
    }
    
    // MARK: public
    public var items: [BarChartGroupItem] = [
        BarChartGroupItem(
            items: [
                BarChartItem(value: 2, color: UIColor.systemGray),
                BarChartItem(value: 3, color: UIColor.systemGray2),
                BarChartItem(value: 4, color: UIColor.systemGray3)
            ]
        ),
        BarChartGroupItem(
            items: [
                BarChartItem(value: 3, color: UIColor.systemGray4),
                BarChartItem(value: 4, color: UIColor.systemGray5)
            ]
        )
    ] {
        // TODO: load default data when empty
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - private
    private var contentView = UIView()
    
    // MARK: user custom
    /// space between groups
    private let groupSpace: CGFloat
    /// space between items
    private let itemSpace: CGFloat
    private let groupLabelWidth: CGFloat
    private let itemLabelWidth: CGFloat
    private let spaceBetweenBarAndDescriptionLabel: CGFloat
    private let animationDelayInterval: Double
    private let barCornerRadius: CGFloat
    private let averageLineInfo: AverageLineInfo?
    private let minimumBarWidth: CGFloat
    /// Bool indicating pause animation at the beginning.
    let isAnimationPaused: Bool
    
    // MARK: calculated
    private var showGroupLabel              = false
    private var showItemLabel               = false
    private var showDescriptionLabel        = false
    private var didAnimation                = false
    
    private var itemHeight: CGFloat         = 0
    private var maxBarWidth: CGFloat        = 0
    private var descriptionLabelWidth: CGFloat = 0
    
    private var maxValue: CGFloat           = 0
    
    // MARK: average line
    private var averageLineLayer = CAShapeLayer()
    private var averageValue: CGFloat               = 0
    private var averageLineAnimationDelay: Double    = 0.0
        
    private var groupPoints: [BarPoint] = []
    private var bars: [UIView] = []
    
    public var averageLineXPos: CGFloat = 0
    
    // TODO: add margins
    
    // MARK: - init
    /// - Parameters:
    ///   - frame: frame of chart
    ///   - groupSpace: space between groups. Default 10
    ///   - itemSpace: space between items. Default 3
    ///   - groupLabelWidth: width of group text label. Default 52
    ///   - itemLabelWidth: width of item text label. Default 52
    ///   - animationDelayInterval : interval between animation start time for each bar. Default 0.3
    ///   - showAverageLine : Default false
    ///   - averageLineColor: color of average line. Default systemRed
    ///   - barCornerRadius: cornerRadius of bar. Default 0
    ///   - spaceBetweenBarAndDescriptionLabel: Default 0
    ///   - isAnimationPaused: Pause animation at the beginning. Default false.
    public init(frame: CGRect, groupSpace: CGFloat = 10, itemSpace: CGFloat = 3, groupLabelWidth: CGFloat = 52, itemLabelWidth: CGFloat = 52, descriptionLabelWidth: CGFloat = 52, animationDelayInterval: Double = 0.3, barCornerRadius: CGFloat = 0, averageLine: AverageLineInfo? = nil, spaceBetweenBarAndDescriptionLabel: CGFloat = 0, minimumBarWidth: CGFloat = 0, isAnimationPaused: Bool = false) {
        self.groupSpace = groupSpace
        self.itemSpace = itemSpace
        self.groupLabelWidth = groupLabelWidth
        self.itemLabelWidth = itemLabelWidth
        self.animationDelayInterval = animationDelayInterval
        self.averageLineInfo = averageLine
        self.barCornerRadius = barCornerRadius
        self.spaceBetweenBarAndDescriptionLabel = spaceBetweenBarAndDescriptionLabel
        self.minimumBarWidth = minimumBarWidth
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
extension BarChart {
    public func resumeAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.didAnimation else { return }

            for (index, bar) in self.bars.enumerated() {
                self.resumeAnimation(layer: bar.layer, delay: Double(index) * self.animationDelayInterval)
            }
            
            if self.averageLineInfo != nil {
                self.resumeAnimation(layer: self.averageLineLayer, delay: self.averageLineAnimationDelay)
            }
            
            self.didAnimation = true
        }
    }
}

// MARK: - private
extension BarChart {
    func reset() {
        subviews.forEach{ $0.removeFromSuperview() }
        // TODO: items.removeAll()
        bars.removeAll()
        
        contentView.removeFromSuperview()
        contentView = UIView(frame: bounds)
        addSubview(contentView)
        
        maxValue = 1
        descriptionLabelWidth = 0
        
        showGroupLabel = false
        showItemLabel = false
        showDescriptionLabel = false
        didAnimation = false
    }
}
 
// MARK: - data
extension BarChart {
    func calculateChartData() {
        let groupCount = items.count
        var itemCount: Int = 0
        var totalValue: CGFloat = 0
        var maxItemCountInGroup = 0
        
        let labelForCalculatingWidth = UILabel()
        
        for group in items {
            showGroupLabel = showGroupLabel || group.label != nil
            itemCount += group.items.count
            maxItemCountInGroup = max(maxItemCountInGroup, group.items.count)
            
            for item in group.items {
                showItemLabel = showItemLabel || item.label != nil
                showDescriptionLabel = showDescriptionLabel || item.descriptionLabel != nil
                maxValue = max(maxValue, item.value)
                totalValue += item.value
                
                if let labelInfo = item.descriptionLabel {
                    labelForCalculatingWidth.text = labelInfo.text
                    labelForCalculatingWidth.font = labelInfo.font
                    labelForCalculatingWidth.sizeToFit()
                    descriptionLabelWidth = max(descriptionLabelWidth, labelForCalculatingWidth.bounds.size.width+spaceBetweenBarAndDescriptionLabel)
                }
            }
        }
        
        averageValue = totalValue / CGFloat(itemCount)
        let groupSpaceCount = items.count - 1
        let itemSpaceCount = itemCount - groupCount
        var totalSpace = (groupSpace * CGFloat(groupSpaceCount)) + (itemSpace * CGFloat(itemSpaceCount))
        
        if let averageLineInfo = averageLineInfo { totalSpace += averageLineInfo.bottomSpaceAreaHeight}
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

// MARK: - draw
extension BarChart {
    func drawChart() {
        for (groupIndex, group) in items.enumerated() {
            drawGroup(group, at: groupPoints[groupIndex])
        }
        
        if let averageLineInfo = averageLineInfo {
            drawAverageLine(info: averageLineInfo)
        }
    }
    
    private func drawAverageLine(info: AverageLineInfo) {
        var xPos: CGFloat = maxBarWidth * (averageValue / maxValue)
        
        if xPos == 0 { xPos += minimumBarWidth / 2 }
        else if xPos == maxBarWidth { xPos -= minimumBarWidth / 2 }
                    
        if showGroupLabel { xPos += groupLabelWidth }
        if showItemLabel { xPos += itemLabelWidth }
        
        averageLineLayer = createDashLine(xPos: xPos, color: info.lineColor)
        averageLineXPos = xPos
        contentView.layer.addSublayer(averageLineLayer)
    }
    
    private func drawGroup(_ group: BarChartGroupItem, at point: BarPoint) {
        let groupLabelHeight = point.bottomRightPoint.y - point.topLeftPoint.y

        if showGroupLabel {
            let label = createLabel(frame: CGRect(x: point.topLeftPoint.x, y: point.topLeftPoint.y, width: groupLabelWidth, height: groupLabelHeight), labelItem: group.label!, align: .left)
            contentView.addSubview(label)
        }
        
        for (itemIndex, item) in group.items.enumerated() {
            drawItem(item, at: point.subPoints[itemIndex], index: itemIndex)
        }
    }
    
    private func drawItem(_ item: BarChartItem, at point: BarPoint, index: Int) {
        let barWidth: CGFloat = max(maxBarWidth * (item.value / maxValue), minimumBarWidth)
        var itemLabelX: CGFloat = point.topLeftPoint.x, barX: CGFloat = point.topLeftPoint.x, descriptionLabelX: CGFloat = maxBarWidth
        
        if showGroupLabel {
            itemLabelX += groupLabelWidth
            barX += groupLabelWidth
            descriptionLabelX += groupLabelWidth
        }
        
        if showItemLabel {
            barX += itemLabelWidth
            descriptionLabelX += itemLabelWidth
            
            let label = createLabel(frame: CGRect(x: itemLabelX, y: point.topLeftPoint.y+1, width: itemLabelWidth, height: itemHeight-2), labelItem: item.label!, align: .left)
            contentView.addSubview(label)
        }
        
        let bar = createBar(frame: CGRect(x: barX, y: point.topLeftPoint.y, width: barWidth, height: itemHeight), item: item, delay: Double(index) * animationDelayInterval)
        contentView.addSubview(bar)
        bars.append(bar)
        
        if showDescriptionLabel {
            let descriptionLabel = createLabel(frame: CGRect(x: descriptionLabelX, y: point.topLeftPoint.y, width: descriptionLabelWidth, height: itemHeight), labelItem: item.descriptionLabel!, align: .right)
            contentView.addSubview(descriptionLabel)
        }
    }
}

// MARK: - animation
extension BarChart {
    func addAnimation() {
        for (index, bar) in bars.enumerated() {
            let barWidth = bar.bounds.size.width
            bar.frame.size.width = 0
            
            let growAnimation = ChartAnimationFactory.createAnimation(type: .growWidth(finalWidth: barWidth), duration: 1, beginTimeDelay: Double(index) * animationDelayInterval, timingFunctionName: .easeInEaseOut, isRemovedOnCompletion: false, fillMode: .forwards)
            bar.layer.add(growAnimation, forKey: "growAnimation")
            
            let fadeInAnimation = ChartAnimationFactory.createAnimation(type: .fadeIn, duration: 1.2, beginTimeDelay: averageLineAnimationDelay, timingFunctionName: .easeOut, isRemovedOnCompletion: false, fillMode: .forwards)
            averageLineLayer.add(fadeInAnimation, forKey: "fadeIn")
        }
    }
    
    func pauseAnimation() {
        for bar in bars {
            pauseAnimation(layer: bar.layer)
        }
        
        if averageLineInfo != nil {
            pauseAnimation(layer: averageLineLayer)
        }
    }
}

// MARK: - view
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
        view.layer.anchorPoint = CGPoint(x: 0, y: 0)
        view.frame = frame
        view.layer.cornerRadius = barCornerRadius
        return view
    }
    
    private func createDashLine(xPos: CGFloat, color: UIColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [3,3]
        shapeLayer.opacity = 0
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: xPos, y: 0), CGPoint(x: xPos, y: frame.height)])
        shapeLayer.path = path
        
        return shapeLayer
    }
}
