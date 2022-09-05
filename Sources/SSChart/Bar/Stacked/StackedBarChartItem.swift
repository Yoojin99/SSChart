//
//  StackedBarChartItem.swift
//  
//
//  Created by YJ on 2022/09/02.
//

import UIKit

public struct StackedBarChartItem {
    let value: CGFloat
    let color: UIColor
    
    /// - Parameters:
    ///   - value: value of item
    ///   - color: color to fill section of bar
    public init(value: CGFloat, color: UIColor = UIColor.systemGreen) {
        self.value = value
        self.color = color
    }
}
