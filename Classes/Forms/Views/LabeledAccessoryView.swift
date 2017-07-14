//
//  LabeledAccessoryView.swift
//  MPOLKit
//
//  Created by Rod Brown on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1

/// An accessory view providing a title and subtitle label, and an optional
/// additional embedded view.
///
/// `LabeledAccessoryView` is designed to be used as an accessory in a
/// `CollectionViewFormCell`
open class LabeledAccessoryView: UIView {
    
    public let titleLabel = UILabel(frame: .zero)
    
    public let subtitleLabel = UILabel(frame: .zero)
    
    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var accessoryView: UIView? {
        didSet {
            if oldValue != accessoryView {
                oldValue?.removeFromSuperview()
                oldValue?.removeObserver(self, forKeyPath: #keyPath(UIView.isHidden), context: &kvoContext)
                
                if let newAccessoryView = accessoryView {
                    newAccessoryView.addObserver(self, forKeyPath: #keyPath(UIView.isHidden), context: &kvoContext)
                    addSubview(newAccessoryView)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    
    // MARK : - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
            subtitleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
        }
    }
    
    deinit {
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            subtitleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
        }
        accessoryView?.removeObserver(self, forKeyPath: #keyPath(UIView.isHidden), context: &kvoContext)
    }
    
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Get constants
        let size = bounds.size
        let displayScale = traitCollection.currentDisplayScale
        let isRightToLeft = traitCollection.layoutDirection == .rightToLeft
        
        // Size content
        let accessorySize = accessoryView?.sizeThatFits(size).constrained(to: size) ?? .zero
        
        var availableTitleSize = size
        let accessoryWidth = (accessorySize.isEmpty ? 0.0 : CollectionViewFormCell.accessoryContentInset + accessorySize.width).ceiled(toScale: displayScale)
        
        availableTitleSize.width = max(availableTitleSize.width - accessoryWidth, 0.0)
        
        let titleSize    = titleLabel.sizeThatFits(availableTitleSize).constrained(to: availableTitleSize)
        let subtitleSize = subtitleLabel.sizeThatFits(availableTitleSize).constrained(to: availableTitleSize)
        
        let titleVisible = titleSize.isEmpty == false && titleLabel.isHidden == false
        let subtitleVisible = subtitleSize.isEmpty == false && subtitleLabel.isHidden == false
        
        let labelSeparation = titleVisible && subtitleVisible ? self.labelSeparation : 0.0
        let heightForLabelContent = (titleVisible ? titleSize.height : 0.0) + (subtitleVisible ? subtitleSize.height : 0) + labelSeparation
        
        
        // Position content
        accessoryView?.frame = CGRect(origin: CGPoint(x: isRightToLeft ? 0.0 : size.width - accessorySize.width,
                                                      y: ((size.height - accessorySize.height) / 2.0).rounded(toScale: displayScale)),
                                      size: accessorySize)
        
        var currentYOffset = ((size.height - heightForLabelContent) / 2.0).rounded(toScale: displayScale)
        
        titleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? accessorySize.width: size.width - accessoryWidth - titleSize.width, y: currentYOffset),
                                  size: titleSize)
        if titleVisible {
            currentYOffset += (titleSize.height + labelSeparation).rounded(toScale: displayScale)
        }
        
        subtitleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? accessorySize.width: size.width - accessoryWidth - subtitleSize.width, y: currentYOffset),
                                     size: subtitleSize)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let accessorySize = accessoryView?.isHidden ?? true ? .zero : accessoryView!.sizeThatFits(size).constrained(to: size)
        
        var availableTitleSize = size
        let accessoryWidth = accessorySize.isEmpty ? 0.0 : (accessorySize.width + CollectionViewFormCell.accessoryContentInset).ceiled(toScale: traitCollection.currentDisplayScale)
        availableTitleSize.width = max(availableTitleSize.width - accessoryWidth, 0.0)
        
        let titleSize    = titleLabel.isHidden    ? .zero : titleLabel.sizeThatFits(availableTitleSize).constrained(to: availableTitleSize)
        let subtitleSize = subtitleLabel.isHidden ? .zero : subtitleLabel.sizeThatFits(availableTitleSize).constrained(to: availableTitleSize)
        let titleSeparation = titleSize.isEmpty == false && subtitleSize.isEmpty == false ? labelSeparation : 0.0
        
        return CGSize(width: max(titleSize.width, subtitleSize.width) + accessoryWidth,
                      height: max(titleSize.height + subtitleSize.height + titleSeparation, accessorySize.height)).constrained(to: size)
    }
    
    
    // MARK: - Changes
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory || traitCollection.currentDisplayScale != previousTraitCollection?.currentDisplayScale {
            setNeedsLayout()
        }
        
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
