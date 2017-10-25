//
//  EntityListCollectionViewCell.swift
//  MPOL
//
//  Created by Rod Brown on 6/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1

open class EntityListCollectionViewCell: CollectionViewFormCell {
    
    // MARK: - Public properties
    
    public let thumbnailView: EntityThumbnailView = EntityThumbnailView(frame: .zero)
    
    public let sourceLabel: RoundedRectLabel = RoundedRectLabel(frame: .zero)
    
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    public let subtitleLabel: UILabel = UILabel(frame: .zero)
    
    
    open var actionCount: UInt = 0 {
        didSet {
            
            if actionCount == oldValue { return }
            
            badgeView.text = String(describing: actionCount)
            badgeView.isHidden = actionCount == 0
            setNeedsLayout()
        }
    }
    
    
    open var borderColor: UIColor? {
        didSet {
            if borderColor == oldValue { return }
            
            badgeView.backgroundColor = borderColor ?? .gray
        }
    }
    
    
    // MARK: - Private/internal properties
    
    private let textLayoutGuide = UILayoutGuide()
    
    private var sourceTitleHorizontalConstraint: NSLayoutConstraint!
    
    private let badgeView = BadgeView(style: .system)
    
    
    
    // MARK: - Initialization
    
    override open func commonInit() {
        super.commonInit()
        
        accessibilityTraits |= UIAccessibilityTraitStaticText
        
        let contentView       = self.contentView
        let borderedImageView = self.thumbnailView
        let sourceLabel       = self.sourceLabel
        let titleLabel        = self.titleLabel
        let subtitleLabel     = self.subtitleLabel
        
        badgeView.translatesAutoresizingMaskIntoConstraints         = false
        borderedImageView.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.translatesAutoresizingMaskIntoConstraints       = false
        titleLabel.translatesAutoresizingMaskIntoConstraints        = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints     = false
        
        sourceLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        
        let traitCollection = self.traitCollection
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(borderedImageView)
        contentView.addSubview(badgeView)
        
        let textLayoutGuide        = self.textLayoutGuide
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        contentView.addLayoutGuide(textLayoutGuide)
        
        sourceLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        sourceLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        subtitleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        
        sourceTitleHorizontalConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal, toItem: sourceLabel, attribute: .trailing, constant: 8.0)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: borderedImageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: borderedImageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: borderedImageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: borderedImageView, attribute: .width,   relatedBy: .equal, toConstant: 48.0),
            NSLayoutConstraint(item: borderedImageView, attribute: .height,  relatedBy: .equal, toConstant: 48.0),
            
            NSLayoutConstraint(item: badgeView, attribute: .centerX, relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: -2.0),
            NSLayoutConstraint(item: badgeView, attribute: .centerY, relatedBy: .equal, toItem: borderedImageView, attribute: .top,      constant: 2.0),
            
            NSLayoutConstraint(item: sourceLabel, attribute: .leading, relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: sourceLabel, attribute: .centerY, relatedBy: .equal, toItem: titleLabel,      attribute: .centerY),
            
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom,   relatedBy: .equal,           toItem: textLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: titleLabel, attribute: .bottom, constant: CellTitleSubtitleSeparation),
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: sourceLabel, attribute: .bottom, constant: CellTitleSubtitleSeparation),
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: textLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual,   toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: 16.0),
            
            NSLayoutConstraint(item: borderedImageView, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),
            
            sourceTitleHorizontalConstraint
        ])
        
        sourceLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        sourceLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    deinit {
        sourceLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        sourceLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return [titleLabel, subtitleLabel].flatMap({ $0.text }).joined(separator: ", ")
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            // Drop the source title separation if the source label has no text.
            sourceTitleHorizontalConstraint.constant = sourceLabel.text?.isEmpty ?? true ? 0.0 : 8.0
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content height for a cell, considering the text details.
    ///
    /// - Parameters: - traitCollection:    The trait collection the cell will be displayed in.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let titleFont    = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        let subtitleFont = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        
        let displayScale = traitCollection.currentDisplayScale
        return max(titleFont.lineHeight.ceiled(toScale: displayScale) + subtitleFont.lineHeight.ceiled(toScale: displayScale), 48.0)
    }
    
}
