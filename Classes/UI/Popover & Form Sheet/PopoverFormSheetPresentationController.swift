//
//  PopoverFormSheetPresentationController.swift
//  MPOLKit
//
//  Created by Rod Brown on 1/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A presentation controller for presenting view controllers in the `UIModalPresentationStyle.formSheet`
/// style, except with a popover style blurred background. `PopoverFormSheetPresentationController`
/// handles keyboard appearance to shift the view controller for optimal text entry, just like
/// `UIModalPresentationStyle.formSheet`.
///
/// `PopoverFormSheetPresentationController` also conforms to `UIViewControllerAnimatedTransitioning`
/// and provides an implementation for a standard form sheet presentation, with a little added "bounce".
public class PopoverFormSheetPresentationController: UIPresentationController, UIViewControllerAnimatedTransitioning {
    
    
    public override var presentedView: UIView? {
        return presentationWrappingView
    }
    
    private var presentationWrappingView: UIVisualEffectView?
    
    private var dimmingView: UIView?
    
    private var keyboardInset: CGFloat = 0.0
    
    
    // MARK: - Initializers
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)),  name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)),  name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Presentation state start/end handlers
    
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        let presentationWrappingView = UIVisualEffectView(effect: UIBlurEffect(style: Theme.current.isDark ? .dark : .extraLight))
        presentationWrappingView.clipsToBounds = true
        presentationWrappingView.layer.cornerRadius = 10.0
        self.presentationWrappingView = presentationWrappingView
        
        if let presentedViewControllerView = super.presentedView {
            let contentView = presentationWrappingView.contentView
            presentedViewControllerView.frame = contentView.bounds
            presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(presentedViewControllerView)
        }
        
        let dimmingView = UIView(frame: containerView?.bounds ?? .zero)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.16)
        dimmingView.alpha = 0.0
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView?.addSubview(dimmingView)
        self.dimmingView = dimmingView
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext) in
            dimmingView.alpha = 1.0
        })
    }
    
    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        let dimmingView = self.dimmingView
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext) in
            dimmingView?.alpha = 0.0
        })
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView?.removeFromSuperview()
        }
        super.dismissalTransitionDidEnd(completed)
    }
    
    
    // MARK: - Sizing
    
    public override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        var containerSize = container.preferredContentSize
        if containerSize.width  <=~ 0.0 { containerSize.width  = 540.0 }
        if containerSize.height <=~ 0.0 { containerSize.height = 620.0 }
        
        containerSize.width  = min(parentSize.width, containerSize.width)
        containerSize.height = min(parentSize.height, containerSize.height)
        return containerSize
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        let containerBounds = containerView?.bounds ?? .zero
        let presentedViewSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        
        let displayScale = traitCollection.currentDisplayScale
        let contentOrigin = CGPoint(x: (containerBounds.midX - (presentedViewSize.width / 2.0)).rounded(toScale: displayScale),
                                    y: (containerBounds.midY - (presentedViewSize.height / 2.0)).floored(toScale: displayScale))
        var positionedRect = CGRect(origin: contentOrigin, size: presentedViewSize)
        
        let containerHeightWithoutKeyboard = containerBounds.height - keyboardInset
        if positionedRect.maxY > containerHeightWithoutKeyboard {
            positionedRect.origin.y = ((containerHeightWithoutKeyboard - presentedViewSize.height) / 2.0).floored(toScale: displayScale)
        }
        
        positionedRect.origin.y = max(positionedRect.origin.y, presentingViewController.topLayoutGuide.length)
        return positionedRect
    }

    
    // MARK: - Layout
    
    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        containerView?.setNeedsLayout()
        
        UIView.animate(withDuration: 0.2) {
            self.containerView?.layoutIfNeeded()
        }
    }
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        dimmingView?.alpha = 1.0
        presentationWrappingView?.frame = frameOfPresentedViewInContainerView
    }
    
    
    // MARK: - UIViewControllerAnimatedTransitioning methods
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated ?? true ? 0.6 : 0.0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController   = transitionContext.viewController(forKey: .to),
            let containerView      = self.containerView else {
                return
        }
        
        // For a Presentation:
        //      fromView = The presenting view.
        //      toView   = The presented view.
        // For a Dismissal:
        //      fromView = The presented view.
        //      toView   = The presenting view.
        
        let fromView = transitionContext.view(forKey: .from)
        let toView   = transitionContext.view(forKey: .to)
        
        let isPresenting = fromViewController == presentingViewController
        
        if let toView = toView {
            containerView.addSubview(toView)
        }
        
        if isPresenting {
            fromView?.frame = transitionContext.finalFrame(for: fromViewController)
            
            var toViewFrame = transitionContext.finalFrame(for: toViewController)
            toViewFrame.origin.y = containerView.bounds.maxY
            toView?.frame = toViewFrame
        }
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: transitionDuration, delay: 0.0, usingSpringWithDamping: isPresenting ? 0.6 : 1.0, initialSpringVelocity: 0.0, animations: {
            if isPresenting {
                toView?.frame = transitionContext.finalFrame(for: toViewController)
            } else {
                var finalFrame = self.frameOfPresentedViewInContainerView
                finalFrame.origin.y = containerView.bounds.maxY
                fromView?.frame = finalFrame
            }
        }, completion: { (finished: Bool) in
            // When we complete, tell the transition context
            // passing along the BOOL that indicates whether the transition
            // finished or not.
            
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        })
    }
    
    
    // MARK: - Private methods
    
    @objc private func applyCurrentTheme() {
        presentationWrappingView?.effect = UIBlurEffect(style: Theme.current.isDark ? .dark : .extraLight)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let keyboardAnimationDetails = notification.keyboardAnimationDetails()
        let keyboardInset = keyboardAnimationDetails?.endFrame.height ?? 0.0
        
        setKeyboardInset(keyboardInset, animationDetails: keyboardAnimationDetails)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        setKeyboardInset(0.0, animationDetails: notification.keyboardAnimationDetails())
    }
    
    private func setKeyboardInset(_ inset: CGFloat, animationDetails: KeyboardAnimationDetails?) {
        let containerView = self.containerView
        
        keyboardInset = inset
        containerView?.setNeedsLayout()
        
        guard let details = animationDetails, details.duration >~ 0.0 else { return }
        
        UIView.animate(withDuration: details.duration, delay: 0.0, options: details.curve, animations: {
            containerView?.layoutIfNeeded()
        })
    }
    
}
