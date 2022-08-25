//
//  BarChartItem.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/17.
//

import Foundation
import UIKit

public struct BarChartGroupItem {
    let items: [BarChartItem]
    let label: BarChartLabelItem?
    
    public init(items: [BarChartItem], label: BarChartLabelItem? = nil) {
        self.items = items
        self.label = label
    }
}

public struct BarChartItem {
    let value: CGFloat
    let label: BarChartLabelItem?
    let color: UIColor
    let descriptionLabel: BarChartLabelItem?
    
    /// - Parameters:
    ///   - value: value of item
    ///   - label: title for item
    ///   - color: color to fill bar. Default systemGreen
    ///   - descriptionLabel: description for item that appears right side of the bar
    public init(value: CGFloat, label: BarChartLabelItem? = nil, color: UIColor = .systemGreen, descriptionLabel: BarChartLabelItem? = nil) {
        self.value = value
        self.label = label
        self.color = color
        self.descriptionLabel = descriptionLabel
    }
}

public struct BarChartLabelItem {
    let text: String
    let font: UIFont
    let textColor: UIColor
    
    /// - Parameters:
    ///   - text: label text
    ///   - font: label font. Default systemFont of Size 12, weight bold
    ///   - color: label textColor. Default black
    public init(text: String, font: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold), textColor: UIColor = UIColor.black) {
        self.text = text
        self.font = font
        self.textColor = textColor
    }
}
