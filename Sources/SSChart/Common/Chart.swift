//
//  Chart.swift
//  SwiftChart
//
//  Created by YJ on 2022/08/17.
//

import Foundation
import UIKit

protocol Chart {
    var isAnimationPaused: Bool { get }
    
    func reload()
    func reset()
    func calculateChartData()
    func drawChart()
    func addAnimation()
    
    func pauseAnimation()
    func resumeAnimation()
}

extension Chart {
    func reload() {
        reset()
        calculateChartData()
        drawChart()
        addAnimation()
        
        if isAnimationPaused {
            pauseAnimation()
        }
    }
    
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
