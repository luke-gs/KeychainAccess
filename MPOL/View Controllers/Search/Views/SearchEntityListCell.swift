//
//  SearchEntityListCell.swift
//  MPOL
//
//  Created by Rod Brown on 6/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// TODO: This class will need to be merged into the kit after demo
class SearchEntityListCell: CollectionViewFormCell {

    // MARK: - Public properties
    
    var thumbnailView: EntityThumbnailView = EntityThumbnailView(frame: .zero)
    
    let sourceLabel: RoundedRectLabel = RoundedRectLabel(frame: .zero)
    
    let titleLabel: UILabel = UILabel(frame: .zero)
    
    let subtitleLabel: UILabel = UILabel(frame: .zero)
    
    
    var alertCount: UInt = 0 {
        didSet {
            if alertCount == oldValue { return }
            
            badgeView.text = String(describing: alertCount)
            setNeedsLayout()
        }
    }
    
    
    public var alertColor: UIColor? {
        didSet {
            if alertColor == oldValue { return }
            
            badgeView.backgroundColor = alertColor ?? .gray
        }
    }
    
    
    // MARK: - Private/internal properties
    
    private let textLayoutGuide = UILayoutGuide()
    
    private let badgeView = BadgeView(style: .system)
    
    
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        accessibilityTraits |= UIAccessibilityTraitStaticText
        
        let contentView       = self.contentView
        let borderedImageView = self.thumbnailView
        let sourceLabel       = self.sourceLabel
        let titleLabel        = self.titleLabel
        let subtitleLabel     = self.subtitleLabel
        
        applyStandardFonts()
        
        badgeView.translatesAutoresizingMaskIntoConstraints         = false
        borderedImageView.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.translatesAutoresizingMaskIntoConstraints       = false
        titleLabel.translatesAutoresizingMaskIntoConstraints        = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints     = false
        
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(borderedImageView)
        contentView.addSubview(badgeView)
        
        let textLayoutGuide        = self.textLayoutGuide
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        contentView.addLayoutGuide(textLayoutGuide)
        
        sourceLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        subtitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
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
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: sourceLabel,     attribute: .trailing, constant: 8.0),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom,   relatedBy: .equal,           toItem: textLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: titleLabel, attribute: .bottom, constant: 2.0),
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: sourceLabel, attribute: .bottom, constant: 2.0),
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: textLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual,   toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: 16.0),
            
            NSLayoutConstraint(item: borderedImageView,       attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow)
        ])
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
    
    private func applyStandardFonts() {
        //super.applyStandardFonts()
        
        if #available(iOS 10, *) {
            let traitCollection = self.traitCollection
            titleLabel.font    = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        } else {
            titleLabel.font    = .preferredFont(forTextStyle: .headline)
            subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        }
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content height for a cell, considering the text details.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - subtitle:           The subtitle text for the cell.
    ///   - width:              The width constraint for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let titleFont:    UIFont
        let subtitleFont: UIFont
        
        if #available(iOS 10, *) {
            titleFont    = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            subtitleFont = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        } else {
            titleFont    = .preferredFont(forTextStyle: .headline)
            subtitleFont = .preferredFont(forTextStyle: .footnote)
        }
        
        let displayScale = traitCollection.currentDisplayScale
        return max(titleFont.lineHeight.ceiled(toScale: displayScale) + subtitleFont.lineHeight.ceiled(toScale: displayScale), 48.0)
    }

}
