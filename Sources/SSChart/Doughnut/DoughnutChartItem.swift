//
//  DoughnutChartItem.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/17.
//

import Foundation
import UIKit

public struct DoughnutChartItem {
    let value: CGFloat
    let color: UIColor
    let text: String?
    
    /// - Parameters:
    ///   - value: value of item
    ///   - color: color to fill. Default systemGreen
    ///   - text: title of item
    public init(value: CGFloat, color: UIColor = UIColor.systemGreen, text: String? = nil) {
        self.value = value
        self.color = color
        self.text = text
    }
}
