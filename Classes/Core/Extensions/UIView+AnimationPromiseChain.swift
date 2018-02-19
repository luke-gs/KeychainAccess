//
//  UIView+AnimationPromiseChain.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/2/18.
//  Copyright © 2018 Herli Halim. All rights reserved.
//

import UIKit
import PromiseKit

// Extension to UIView.`animate` variant that swapped completion handler to a promise with `Bool`
// so the animation can be chained slightly easier.
extension UIView {

    public class func animate(withDuration duration: TimeInterval, animations: @escaping () -> Void) -> Promise<Bool> {
        return Promise(resolvers: { fulfill, _ in
            UIView.animate(withDuration: duration, animations: animations, completion: { completed in
                fulfill(completed)
            })
        })
    }

    public class func animate(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions = [], animations: @escaping () -> Void) -> Promise<Bool> {
        return Promise(resolvers: { fulfill, _ in
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: { (completed) in
                fulfill(completed)
            })
        })
    }

    public class func animateKeyframes(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewKeyframeAnimationOptions = [], animations: @escaping () -> Void) -> Promise<Bool> {
        return Promise(resolvers: { fulfill, _ in
            UIView.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: animations, completion: { completed in
                fulfill(completed)
            })
        })
    }

    public class func animate(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions = [], animations: @escaping () -> Void) -> Promise<Bool> {
        return Promise(resolvers: { fulfill, _ in
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations, completion: { completed in
                fulfill(completed)
            })
        })
    }
}
