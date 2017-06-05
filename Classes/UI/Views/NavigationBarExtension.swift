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
    
    
    @objc open dynamic var barStyle: UIBarStyle = .default {
        didSet {
            if barStyle == oldValue { return }
            
            if shadowImageView.image == nil {
                shadowImageView.backgroundColor = defaultShadowColor(for: barStyle)
            }
        }
    }
    
    
    /// The background image for the bar extension. The default is `nil`.
    ///
    /// This property conforms to UIAppearance.
    @objc open dynamic var backgroundImage: UIImage? {
        get {
            return backgroundImageView.image
        }
        set {
            backgroundImageView.image = newValue
        }
    }
    
    
    /// The shadow image at the bottom of the bar. The default is the default
    /// shadow image appearance on UINavigationBar.
    ///
    /// This property conforms to UIAppearance.
    @objc open dynamic var shadowImage: UIImage? {
        get {
            return shadowImageView.image
        }
        set {
            if newValue == nil && shadowImageView.image != nil {
                shadowHeightConstraint.isActive = true
                shadowImageView.backgroundColor = defaultShadowColor(for: barStyle)
            } else if newValue != nil && shadowImageView.image == nil {
                shadowHeightConstraint.isActive = false
                shadowImageView.backgroundColor = .clear
            }
            
            shadowImageView.image = newValue
        }
    }
    
    
    // MARK: - Private properties
    
    private let backgroundImageView = UIImageView(frame: .zero)
    
    private let shadowImageView = UIImageView(frame: .zero)
    
    private let shadowHeightConstraint: NSLayoutConstraint
    
    private var _contentView: UIView?
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        shadowHeightConstraint = NSLayoutConstraint(item: shadowImageView, attribute: .height, relatedBy: .equal, toConstant: 1.0 / UIScreen.main.scale)
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        shadowHeightConstraint = NSLayoutConstraint(item: shadowImageView, attribute: .height, relatedBy: .equal, toConstant: 1.0 / UIScreen.main.scale)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
        preservesSuperviewLayoutMargins = false
        
        backgroundImageView.frame = bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundImageView)
        
        shadowImageView.translatesAutoresizingMaskIntoConstraints = false
        shadowImageView.backgroundColor = defaultShadowColor(for: barStyle)
        addSubview(shadowImageView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: shadowImageView, attribute: .leading,  relatedBy: .equal, toItem: self, attribute: .leading),
            NSLayoutConstraint(item: shadowImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing),
            NSLayoutConstraint(item: shadowImageView, attribute: .top,      relatedBy: .equal, toItem: self, attribute: .bottom),
            shadowHeightConstraint
        ])
    }
    
    
    // MARK: - Overrides
    
    open override var intrinsicContentSize: CGSize {
        return contentView?.intrinsicContentSize ?? super.intrinsicContentSize
    }
    
    
    // MARK: - Private
    
    private func defaultShadowColor(for barStyle: UIBarStyle) -> UIColor {
        return barStyle == .default ? UIColor(white: 0.0, alpha: 0.3) : UIColor(white: 1.0, alpha: 0.15) // These are the system bar shadow background colors.
    }
    
}
