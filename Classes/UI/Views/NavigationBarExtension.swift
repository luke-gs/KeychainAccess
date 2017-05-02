//
//  NavigationBarExtension.swift
//  MPOLKit
//
//  Created by Rod Brown on 30/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A view for displaying an extension to the top navigation bar.
///
/// - Important: This is a temporary class that should be refactored with a more
///   fleshed out class when we have decided whether to use components such as
///   TLYShyNavBar etc. This does not implement features such as consistent blur
///   with nav bars etc. It is purely for VicPol release schedule.
open class NavigationBarExtension: UIView {
    
    /// The content for the extension view. The default is `nil`.
    /// 
    /// This view is centered in the view. Setting this directly will update
    /// without animation.
    open var contentView: UIView? {
        get { return _contentView }
        set { setContentView(newValue, animated: false) }
    }
    
    
    /// Updates the content view, with an optional animation.
    ///
    /// - Parameters:
    ///   - contentView: The new content view, or `nil`.
    ///   - animated:    The new
    open func setContentView(_ contentView: UIView?, animated: Bool) {
        let oldView = _contentView
        if oldView == contentView { return }
        
        invalidateIntrinsicContentSize()
        
        _contentView = contentView
        
        if let newView = contentView {
            newView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(newView)
            
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: newView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading),
                NSLayoutConstraint(item: newView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top),
                NSLayoutConstraint(item: newView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, priority: UILayoutPriorityRequired - 1),
                NSLayoutConstraint(item: newView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, priority: UILayoutPriorityRequired - 1),
            ])
            
            newView.alpha = 0.0
        }
        
        UIView.animate(withDuration: animated ? 0.2 : 0.0 , delay: 0.0, options: .beginFromCurrentState, animations: {
            contentView?.alpha = 1.0
            oldView?.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }, completion: { (_: Bool) in
            if (oldView?.alpha ?? 1.0) ==~ 0.0 {
                oldView?.removeFromSuperview()
            }
        })
    }
    
    private let backgroundImageView: UIImageView = UIImageView(frame: .zero)
    
    private var _contentView: UIView?
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
        preservesSuperviewLayoutMargins = false
        
        backgroundImageView.frame = bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundImageView)
    }
    
    
    // MARK: - UIAppearance setters
    
    @objc open dynamic func setBackgroundImage(_ backgroundImage: UIImage?) {
        backgroundImageView.image = backgroundImage
    }
    
    
    // MARK: - Overrides
    
    open override var intrinsicContentSize: CGSize {
        return contentView?.intrinsicContentSize ?? super.intrinsicContentSize
    }
    
}
