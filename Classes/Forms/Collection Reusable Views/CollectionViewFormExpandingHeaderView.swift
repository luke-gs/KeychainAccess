//
//  CollectionViewFormExpandingHeaderView.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var textContext = 1

public class CollectionViewFormExpandingHeaderView: UICollectionReusableView, DefaultReusable {
    
    // MARK: - Sizing
    
    public static let minimumHeight: CGFloat = 36.0
    
    
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
            
            if showsExpandArrow {
                accessibilityTraits |= UIAccessibilityTraitButton
            } else {
                accessibilityTraits &= ~UIAccessibilityTraitButton
            }
        }
    }
    
    
    /// A boolean value indicating whether the expand arrow should be in an expanded state.
    ///
    /// The default is `false`. Setting this updates without an animation.
    public var isExpanded: Bool = false {
        didSet {
            if isExpanded != oldValue {
                arrowView.transform = isExpanded ? .identity :  CGAffineTransform(rotationAngle: CGFloat.pi * (isRightToLeft ? 0.5 : -0.5))
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
    public var tapHandler: ((CollectionViewFormExpandingHeaderView, IndexPath) -> (Void))?
    
    
    // MARK: - Private properties
    
    private let titleLabel    = UILabel(frame: .zero)
    
    private let separatorView = UIView(frame: .zero)
    
    private let arrowView     = UIImageView(image: UIImage(named: "DropDown", in: .mpolKit, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
    
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
        if #available(iOS 10, *) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        }
        
        isAccessibilityElement = true
        
        preservesSuperviewLayoutMargins = false
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * (isRightToLeft ? 0.5 : -0.5))
        arrowView.isHidden = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = tintColor
        titleLabel.font = .systemFont(ofSize: 11.0, weight: UIFontWeightSemibold)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme.current.colors[.Separator]
        
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(arrowView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerDidRecognize)))
        
        separatorHeightConstraint     = NSLayoutConstraint(item: separatorView, attribute: .height,  relatedBy: .equal, toConstant: 1.0 / UIScreen.main.scale)
        titleSeparatorConstraint      = NSLayoutConstraint(item: titleLabel,    attribute: .leading, relatedBy: .equal, toItem: self,       attribute: .leadingMargin)
        separatorSeparationConstraint = NSLayoutConstraint(item: separatorView, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .trailing)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: arrowView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .leadingMargin, constant: (arrowView.image?.size.width ?? 0.0) / 2.0),
            NSLayoutConstraint(item: arrowView, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY),
            
            titleSeparatorConstraint,
            
            separatorSeparationConstraint,
            NSLayoutConstraint(item: separatorView, attribute: .top,      relatedBy: .equal, toItem: titleLabel, attribute: .centerY),
            NSLayoutConstraint(item: separatorView, attribute: .top,      relatedBy: .equal, toItem: self, attribute: .bottomMargin),
            NSLayoutConstraint(item: separatorView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, priority: UILayoutPriorityRequired - 1),
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
        layoutMargins = (layoutAttributes as? CollectionViewFormLayoutAttributes)?.layoutMargins ?? UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            separatorSeparationConstraint.constant = titleLabel.text?.isEmpty ?? true ? 0.0 : 8.0
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel.textColor = tintColor
    }
    
    public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        separatorHeightConstraint.constant = 1.0 / traitCollection.currentDisplayScale
        
        if #available(iOS 10, *) {
            isRightToLeft = self.effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
    }
    
    public override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if semanticContentAttribute == oldValue { return }
            
            if #available(iOS 10, *) {
                isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
            } else {
                isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
            }
        }
    }
    
    
    // MARK: - Accessibility
    
    open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return titleLabel.text
        }
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
    
    
    // MARK: - Private methods
    
    @objc private func tapGestureRecognizerDidRecognize() {
        if let indexPath = self.indexPath {
            tapHandler?(self, indexPath)
        }
    }
    
}
