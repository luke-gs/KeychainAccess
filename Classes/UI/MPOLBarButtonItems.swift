//
//  MPOLBarButtonItems.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


extension UIBarButtonItem {
    
    /// A factory method to create a correctly configured back button item.
    ///
    /// - Parameters:
    ///   - text: The title presented with the button.
    ///   - target: The target for the action when selected.
    ///   - action: The action to fire at the target when selected.
    /// - Returns: A correctly configured UIBarButtonItem.
    public class func backBarButtonItem(text: String? = nil, target: AnyObject?, action: Selector?) -> BackBarButtonItem {
        return BackBarButtonItem(text: text, target: target, action: action)
    }
    
}

/// A UIBarButtonItem for the back button with text.
public class BackBarButtonItem: UIBarButtonItem {
    
    /// The text of the back button.
    public var text: String? {
        didSet {
            backButton.text = text
        }
    }
    
    /// Setting tint color will set the internal backButton views tintColor.
    public override var tintColor: UIColor? {
        didSet {
            backButton.tintColor = tintColor
        }
    }
    
    /// The `BackButton` view used as customView.
    private let backButton: BackButton
    
    public init(text: String?, target: AnyObject?, action: Selector?) {
        backButton = BackButton(text: text)
        
        super.init()
        
        self.accessibilityLabel = NSLocalizedString("Back", comment: "Navigation bar button item accessibility")
        super.customView = backButton
        
        if let selector = action {
            backButton.addTarget(target, action: selector, for: .touchUpInside)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Setting the image is not supported.
    public override var image: UIImage? {
        get { return super.image }
        set { }
    }
    
    /// Setting the title is not supported.
    public override var title: String? {
        get { return super.title }
        set { }
    }
    
    /// Setting the custom view is not supported.
    public override var customView: UIView? {
        get { return super.customView }
        set { }
    }
    
    /// Setting the target is not supported.
    public override var target: AnyObject? {
        get { return super.target }
        set { }
    }
    
    /// Setting the action is not supported.
    public override var action: Selector? {
        get { return super.action }
        set { }
    }
    
}

/// A UIBarButtonItem to toggle between the filtered and unfiltered state.
public class FilterBarButtonItem: UIBarButtonItem {
    
    /// A boolean value indicating whether the filter is active. The default is `false`.
    public var isActive: Bool = false {
        didSet {
            if isActive == oldValue { return }
            
            super.image = AssetManager.shared.image(forKey: isActive ? .filterFilled : .filter )
            
            if isActive {
                self.accessibilityValue = NSLocalizedString("Active", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
            } else {
                self.accessibilityValue = NSLocalizedString("Inactive", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
            }
            
        }
    }
    
    /// Initializes the `FilterBarButtonItem` with an optional target and action.
    ///
    /// - Parameters:
    ///   - target: The target for the action when selected.
    ///   - action: The action to fire at the target when selected.
    public init(target: AnyObject?, action: Selector?) {
        super.init()
        super.image = AssetManager.shared.image(forKey: .filter)
        self.target = target
        self.action = action
        self.accessibilityLabel = NSLocalizedString("Filter", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
        self.accessibilityValue = NSLocalizedString("Inactive", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
    }
    
    /// FilterBarButtonItem does not support NSCoding
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Setting the image is not supported.
    public override var image: UIImage? {
        get { return super.image }
        set { }
    }
    
    /// Setting the title is not supported.
    public override var title: String? {
        get { return super.title }
        set { }
    }
    
}

/// Back button control that provides text label, used as the custom view of `BackBarButtonItem`.
private class BackButton: UIControl {
    
    /// Text of the label
    var text: String? {
        didSet {
            label.text = text
            setNeedsLayout()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            icon.tintColor = tintColor
            label.textColor = tintColor
        }
    }
    
    /// Text label displaying title of presenting VC.
    let label = UILabel()
    
    /// Back button icon
    let icon = UIImageView(image: AssetManager.shared.image(forKey: .back))
    
    
    /// Initializes the button with optional text to display beside back icon.
    init(text: String? = nil) {
        super.init(frame: .zero)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        
        label.textColor = .white
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor),
            icon.topAnchor.constraint(equalTo: topAnchor),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Show highlighted state (simulate behiavour of bar button).
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
}
