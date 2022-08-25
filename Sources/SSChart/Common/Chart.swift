//
//  Chart.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/17.
//

import Foundation
import UIKit

protocol Chart {
    /// pause animation. This should be called after setting items for chart.
    func pauseAnimation()
    func resumeAnimation()
}

extension Chart {
    func pauseAnimation(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = pausedTime
    }
    
    func resumeAnimation(layer: CALayer, delay: Double) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = CACurrentMediaTime() - pausedTime + delay
    }
}
