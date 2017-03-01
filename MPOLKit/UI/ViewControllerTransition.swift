//
//  ViewControllerTransition.swift
//  MPOLKit
//
//  Created by Rod Brown on 16/02/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


/// A `UIViewControllerAnimatedTransitioning` object using a standard `UIViewAnimationOption`
/// for the transition appearance
public final class ViewControllerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView   = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let container = transitionContext.containerView
        
        toView.frame = fromView?.frame ?? container.frame
        container.addSubview(toView)
        
        toView.layoutIfNeeded()
        UIView.transition(from: fromView!, to: toView, duration: transitionDuration(using: transitionContext), options:transition) { (finished: Bool) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
