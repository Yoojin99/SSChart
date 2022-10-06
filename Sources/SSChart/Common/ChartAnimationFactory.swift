//
//  ChartAnimationFactory.swift
//  
//
//  Created by YJ on 2022/09/08.
//

import Foundation
import QuartzCore

enum ChartAnimationType {
    case growWidth(finalWidth: CGFloat)
    case fadeIn
    case strokeEnd
    case moveVertical(value: CGFloat)
    case path(startPath: CGPath, endPath: CGPath)
}

// MARK: - public
final class ChartAnimationFactory {
    
    /// Create animation group
    /// - Parameters:
    ///   - types: animation types
    ///   - timingFunctionName: default .default
    ///   - isRemovedOnCompletion: default true
    ///   - fillMode: default .removed
    static func createAnimationGroup(types: [ChartAnimationType], duration: Double, beginTimeDelay: Double = 0.0, timingFunctionName: CAMediaTimingFunctionName = .default, isRemovedOnCompletion: Bool = true, fillMode: CAMediaTimingFillMode = .removed) -> CAAnimationGroup {
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.beginTime = CACurrentMediaTime() + beginTimeDelay
        animationGroup.isRemovedOnCompletion = isRemovedOnCompletion
        animationGroup.fillMode = fillMode
        animationGroup.timingFunction = CAMediaTimingFunction(name: timingFunctionName)

        animationGroup.animations = types.map({ type in
            createAnimation(of: type)
        })

        return animationGroup
    }
    
    /// Create single animation
    /// - Parameters:
    ///   - type: animation type
    ///   - timingFunctionName: default .default
    ///   - isRemovedOnCompletion: default true
    ///   - fillMode: default .removed
    static func createAnimation(type: ChartAnimationType, duration: Double, beginTimeDelay: Double = 0.0, timingFunctionName: CAMediaTimingFunctionName = .default, isRemovedOnCompletion: Bool = true, fillMode: CAMediaTimingFillMode = .removed) -> CABasicAnimation {
        let animation = createAnimation(of: type)
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + beginTimeDelay
        animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        animation.isRemovedOnCompletion = isRemovedOnCompletion
        animation.fillMode = fillMode
        
        return animation
    }
    
    static private func createAnimation(of type: ChartAnimationType) -> CABasicAnimation {
        switch type {
        case .growWidth(let finalWidth):
            return createGrowWidthAnimation(finalWidth: finalWidth)
        case .fadeIn:
            return createFadeInAnimation()
        case .strokeEnd:
            return createStrokeEndAnimation()
        case .moveVertical(let value):
            return createMoveVerticalAnimation(by: value)
        case .path(let startPath, let endPath):
            return createPathAnimation(from: startPath, to: endPath)
        }
    }
}

// MARK: - keypath
extension ChartAnimationFactory {
    static private func createGrowWidthAnimation(finalWidth: CGFloat) -> CABasicAnimation {
        let growAnimation = createBasicAnimation(with: "bounds.size.width")
        growAnimation.byValue = finalWidth
        return growAnimation
    }
    
    static private func createFadeInAnimation() -> CABasicAnimation {
        let fadeInAnimation = createBasicAnimation(with: "opacity")
        fadeInAnimation.byValue = 1
        return fadeInAnimation
    }
    
    static private func createStrokeEndAnimation() -> CABasicAnimation {
        let strokeEndAnimation = createBasicAnimation(with: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        return strokeEndAnimation
    }
    
    static private func createMoveVerticalAnimation(by value: CGFloat) -> CABasicAnimation {
        let moveUpAnimation = createBasicAnimation(with: "position.y")
        moveUpAnimation.byValue = value
        return moveUpAnimation
    }
    
    static private func createPathAnimation(from: CGPath, to: CGPath) -> CABasicAnimation {
        let pathAnimation = createBasicAnimation(with: "path")
        pathAnimation.fromValue = from
        pathAnimation.toValue = to
        return pathAnimation
    }
}

// MARK: - basic
extension ChartAnimationFactory {
    static private func createBasicAnimation(with keypath: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keypath)
        return animation
    }
}
