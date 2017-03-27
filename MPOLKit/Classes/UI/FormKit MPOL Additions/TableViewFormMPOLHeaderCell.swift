//
//  TableViewFormMPOLHeaderCell.swift
//  MPOL-CAD
//
//  Created by Rod Brown on 10/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var textContext = 1


public class TableViewFormMPOLHeaderCell: UITableViewCell {
    
    // MARK: - Public properties
    
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
    
    
    /// The tint color for the view.
    ///
    /// The titleLabel and optional expansion icon will be tinted this color.
    public override var tintColor: UIColor! {
        get { return super.tintColor }
        set { super.tintColor = newValue }
    }
    
    
    /// A boolean value indicating if the header view is intended for the first section
    /// in the table view.
    ///
    /// This value affects the view's auto layout - derived height, and ensures that the
    /// cell is sized to appear correct within an MPOL layout.
    public var isFirstSection: Bool = false
    
    
    /// The title label for the cell.
    public let titleLabel = UILabel(frame: .zero)
    
    
    /// The separator view for the cell.
    public let separatorView = UIView(frame: .zero)
    
    
    // MARK: - Private properties
    
    private let arrowView = UIImageView(image: UIImage(named: "DropDown", in: .formKit, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
    
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
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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
        accessibilityTraits |= UIAccessibilityTraitHeader
        
        separatorInset.left = 10000.0
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = tintColor
        titleLabel.font = .systemFont(ofSize: 11.0, weight: UIFontWeightBold)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * (isRightToLeft ? 0.5 : -0.5))
        arrowView.isHidden = true
        
        let contentView = self.contentView
        contentView.addSubview(separatorView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowView)
        
        separatorHeightConstraint = NSLayoutConstraint(item: separatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0 / UIScreen.main.scale)
        titleSeparatorConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0)
        separatorSeparationConstraint = NSLayoutConstraint(item: separatorView, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: arrowView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1.0, constant: (arrowView.image?.size.width ?? 0.0) / 2.0),
            NSLayoutConstraint(item: arrowView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -10.0),
            
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -10.0),
            titleSeparatorConstraint,
            
            separatorSeparationConstraint,
            NSLayoutConstraint(item: separatorView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: separatorView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
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
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            separatorSeparationConstraint.constant = titleLabel.text?.isEmpty ?? true ? 0.0 : 8.0
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        var displayScale = traitCollection.displayScale
        if displayScale == 0.0 {
            displayScale = UIScreen.main.scale
        }
        separatorHeightConstraint?.constant = 1.0 / displayScale
        
        if #available(iOS 10, *) {
            isRightToLeft = self.effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel.textColor = tintColor
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: isFirstSection ? 30.0 : 48.0)
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
    
}
