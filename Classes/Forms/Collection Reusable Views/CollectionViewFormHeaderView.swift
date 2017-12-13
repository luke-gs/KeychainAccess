//
//  CollectionViewFormHeaderView.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var textContext = 1


public class CollectionViewFormHeaderView: UICollectionReusableView, DefaultReusable {
    
    // MARK: - Sizing
    
    public static let minimumHeight: CGFloat = 36.0

    private let updatesIndicatorSize: CGFloat = 10
    private let updatesIndicatorOffset: CGFloat = 16
    
    // MARK: - Public properties
    
    /// The text for the MPOL header.
    public var text: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue; setNeedsLayout() }
    }
    
    
    /// The tint color for the view. The text and optional expansion icon will be tinted this color.
    public override var tintColor: UIColor! {
        get { return super.tintColor }
        set { super.tintColor = newValue }
    }
    
    
    /// The separator color.
    public var separatorColor: UIColor? {
        get { return separatorView.backgroundColor }
        set { separatorView.backgroundColor = newValue }
    }
    
    
    /// A boolean value indicating whether the view should display an expand arrow.
    /// 
    /// The default is `false`.
    public var showsExpandArrow: Bool = false {
        didSet {
            if showsExpandArrow == oldValue { return }
            
            arrowView.isHidden = !showsExpandArrow
            titleSeparatorConstraint.constant = showsExpandArrow ? 15.0 : 0.0
        }
    }
    
    /// A boolean value indication whether the updates indicator dot should be shown when collapsed.
    ///
    /// The default is `false`.
    public var showsUpdatesIndicatorWhenCollapsed: Bool = false {
        didSet {
            updatesIndicatorView.isHidden = !(showsUpdatesIndicatorWhenCollapsed && !isExpanded)
        }
    }
    
    /// A boolean value indicating whether the expand arrow should be in an expanded state.
    ///
    /// The default is `false`. Setting this updates without an animation.
    public var isExpanded: Bool = false {
        didSet {
            if isExpanded != oldValue {
                arrowView.transform = isExpanded ? .identity :  CGAffineTransform(rotationAngle: CGFloat.pi * (isRightToLeft ? 0.5 : -0.5))
                updatesIndicatorView.isHidden = !(showsUpdatesIndicatorWhenCollapsed && !isExpanded)
            }
        }
    }

    
    /// Updates the isExpanded property, optionally with animation.
    ///
    /// - Parameters:
    ///   - expanded: A boolean value indicating whether the header should be expanded.
    ///   - animated: A boolean value indicating whether the update should be animated.
    public func setExpanded(_ expanded: Bool, animated: Bool) {
        if isExpanded == expanded { return }
        
        if animated {
            UIView.animate(withDuration: 0.15) {
                self.isExpanded = expanded
            }
        } else {
            isExpanded = expanded
        }
    }
    
    
    /// An optional tap handler closure, passing the header view itself, and the associated
    /// index path.
    public var tapHandler: ((CollectionViewFormHeaderView, IndexPath) -> (Void))? {
        didSet {
            // Disable user interaction when no tap handler is set to avoid gesture interference.
            let hasTapHandler = tapHandler != nil
            isUserInteractionEnabled = hasTapHandler
            
            if hasTapHandler {
                accessibilityTraits |= UIAccessibilityTraitButton
            } else {
                accessibilityTraits &= ~UIAccessibilityTraitButton
            }
        }
    }

    /// Optional action button to be displayed at right of header
    public var actionButton: UIButton? {
        didSet {
            guard actionButton != oldValue else { return }
            if let oldValue = oldValue {
                // Remove old button and associated constraints
                oldValue.removeFromSuperview()
            }
            if let actionButton = actionButton {
                // Make sure action button is not being used in another cell due to cell reuse
                // Ideally we would just clear this in prepareForReuse(), but collection view
                // sometimes configures a new cell before calling that method on old one :(
                if let previousCell = actionButton.superview as? CollectionViewFormHeaderView {
                    // Remove button from old cell
                    previousCell.actionButton = nil
                }

                // Add new button and constaints to shorten separator line at beginning of button
                addSubview(actionButton)
                actionButton.translatesAutoresizingMaskIntoConstraints = false
                actionButton.setContentHuggingPriority(.required, for: .horizontal)
                actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
                NSLayoutConstraint.activate([
                    separatorView.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor),
                    actionButton.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
                    actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                ])
            }
        }
    }

    // MARK: - Private properties
    
    private let titleLabel = UILabel(frame: .zero)
    
    private let separatorView = UIView(frame: .zero)
    
    private let arrowView = UIImageView(image: AssetManager.shared.image(forKey: .dropDown))
    
    private let updatesIndicatorView = UIImageView(frame: .zero)
    
    private var indexPath: IndexPath?
    
    private var separatorHeightConstraint: NSLayoutConstraint!
    
    private var titleSeparatorConstraint: NSLayoutConstraint!
    
    private var separatorSeparationConstraint: NSLayoutConstraint!

    private var isRightToLeft: Bool = false {
        didSet {
            if isRightToLeft == oldValue { return }
            
            if isExpanded == false {
                arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * (isRightToLeft ? 0.5 : -0.5))
            }
        }
    }

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
        isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        isAccessibilityElement = true
        preservesSuperviewLayoutMargins = false
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * (isRightToLeft ? 0.5 : -0.5))
        arrowView.isHidden = true

        updatesIndicatorView.isHidden = true
        updatesIndicatorView.image = UIImage.statusDot(withColor: .secondaryGray)
        updatesIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = tintColor
        titleLabel.font = .systemFont(ofSize: 11.0, weight: UIFont.Weight.semibold)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = iOSStandardSeparatorColor
        
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(arrowView)
        addSubview(updatesIndicatorView)
        
        isUserInteractionEnabled = showsExpandArrow
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performTapAction)))
        
        let layoutMarginsGuide = self.layoutMarginsGuide
        
        titleSeparatorConstraint      = titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
        separatorHeightConstraint     = separatorView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
        separatorSeparationConstraint = separatorView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        
        NSLayoutConstraint.activate([
            arrowView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: (arrowView.image?.size.width ?? 0.0) / 2.0),
            arrowView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            updatesIndicatorView.centerYAnchor.constraint(equalTo: arrowView.centerYAnchor),
            updatesIndicatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: -updatesIndicatorOffset),
            updatesIndicatorView.heightAnchor.constraint(equalToConstant: updatesIndicatorSize),
            updatesIndicatorView.widthAnchor.constraint(equalToConstant: updatesIndicatorSize),
            
            titleLabel.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).withPriority(.defaultHigh),
            
            titleSeparatorConstraint,
            separatorSeparationConstraint,
            separatorHeightConstraint,
        ])
        
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &textContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &textContext)
    }
    
    deinit {
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &textContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &textContext)
    }
    
    
    // MARK: - Overrides
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        indexPath = layoutAttributes.indexPath
        if let layoutAttributes = layoutAttributes as? CollectionViewFormLayoutAttributes {
            layoutMargins = layoutAttributes.layoutMargins
        } else {
            // This breaks anyone using custom layoutMargins, so disabled
            // layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        }
    }
    
    public final override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        separatorHeightConstraint.constant = 1.0 / traitCollection.currentDisplayScale
        
        isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
    }
    
    public override var semanticContentAttribute: UISemanticContentAttribute {
        didSet { isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel.textColor = tintColor
    }

    // MARK: - KVO
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            separatorSeparationConstraint.constant = titleLabel.text?.isEmpty ?? true ? 0.0 : 8.0
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Accessibility
    
    open override var accessibilityLabel: String? {
        get { return super.accessibilityLabel?.ifNotEmpty() ?? titleLabel.text }
        set { super.accessibilityLabel = newValue }
    }
    
    open override var accessibilityValue: String? {
        get {
            if let setValue = super.accessibilityValue {
                return setValue
            }
            if showsExpandArrow == false {
                return nil
            }
            return isExpanded ? "Expanded" : "Collapsed"
        }
        set { super.accessibilityValue = newValue }
    }
    
    open override func accessibilityActivate() -> Bool {
        return performTapAction()
    }
    
    
    // MARK: - Private methods
    
    @objc @discardableResult private func performTapAction() -> Bool {
        if let indexPath = self.indexPath,
            let tapHandler = self.tapHandler {
            tapHandler(self, indexPath)
            return true
        }
        return false
    }
    
}
