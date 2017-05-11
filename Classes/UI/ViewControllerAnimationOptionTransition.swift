//
//  ViewControllerAnimationOptionTransition.swift
//  MPOLKit
//
//  Created by Rod Brown on 16/02/2016.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A `UIViewControllerAnimatedTransitioning` object using a standard `UIViewAnimationOption`
/// for the transition appearance.
public final class ViewControllerAnimationOptionTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public let transition: UIViewAnimationOptions
    public let duration: TimeInterval
    
    public init(transition: UIViewAnimationOptions, duration: TimeInterval = 0.25) {
        self.transition = transition
        self.duration   = duration
        
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        let toView   = transitionContext.view(forKey: .to)
        let container = transitionContext.containerView
        
        let duration = transitionDuration(using: transitionContext)
        
        let completionHandler = { (finished: Bool) in
            transitionContext.completeTransition(transitionContext.transitionWasCancelled == false)
        }
        
        if let toView = toView {
            toView.frame = fromView?.frame ?? container.frame
            container.addSubview(toView)
            
            toView.layoutIfNeeded()
            
            if let fromView = fromView {
                // Do the transition direct.
                UIView.transition(from: fromView, to: toView, duration: duration, options: transition, completion: completionHandler)
                return
            }
            
            // prepare for a standard container transition
            toView.alpha = 0.0
        }
        
        UIView.transition(with: container, duration: duration, options: transition, animations: {
            fromView?.alpha = 0.0
            toView?.alpha   = 1.0
        }, completion: { (finished: Bool) in
            fromView?.alpha = 1.0
            completionHandler(finished)
        })
    }
    
}
