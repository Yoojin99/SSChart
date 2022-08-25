//
//  GaugeChartItem.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/17.
//

import Foundation
import UIKit

public struct GaugeChartItem {
    let value: CGFloat
    let color: UIColor
    
    /// - Parameters:
    ///   - value: value of item
    ///   - color: color to fill. Default systemGreen
    public init(value: CGFloat, color: UIColor = .systemGreen) {
        self.value = value
        self.color = color
    }
}
