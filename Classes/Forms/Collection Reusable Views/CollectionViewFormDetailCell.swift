//
//  CollectionViewFormDetailCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


fileprivate var kvoContext = 1

fileprivate let imageTextInset: CGFloat = 16.0

fileprivate let titleDetailSeparation: CGFloat = 7.0


open class CollectionViewFormDetailCell: CollectionViewFormCell {
    
    
    /// Calculates a minimum height with the standard configuration of single lines
    /// for the title and subtitle, and a double line for detail text
    ///
    /// - Parameter image: An optional size for an image to display at the leading edge of the titles.
    /// - Returns: The correct height for the cell.
    class func minimumContentHeight(withImageSize imageSize: CGSize? = nil, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let fonts = defaultFonts(compatibleWith: traitCollection)
        let displayScale = traitCollection.currentDisplayScale
        
        let titleFontHeight = fonts.titleFont.lineHeight.ceiled(toScale: displayScale) + fonts.subtitleFont.lineHeight.ceiled(toScale: displayScale) + CellTitleSubtitleSeparation
        let titleImageHeight = max(titleFontHeight, imageSize?.height ?? 0.0)
        
        return titleImageHeight + ((fonts.detailFont.lineHeight * 2.0) + fonts.detailFont.leading).ceiled(toScale: displayScale) + titleDetailSeparation
    }
    
    private class func defaultFonts(compatibleWith traitCollection: UITraitCollection) -> (titleFont: UIFont, subtitleFont: UIFont, detailFont: UIFont) {
        
        if #available(iOS 10, *) {
            return (.preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection),
                    .preferredFont(forTextStyle: .footnote,    compatibleWith: traitCollection),
                    .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection))
        } else {
            return (.preferredFont(forTextStyle: .headline),
                    .preferredFont(forTextStyle: .footnote),
                    .preferredFont(forTextStyle: .subheadline))
        }
    }
    
    
    
    // MARK: - Public properties
    
    public let imageView: UIImageView = UIImageView(frame: .zero)
    
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    public let subtitleLabel: UILabel = UILabel(frame: .zero)

    public let detailLabel: UILabel = UILabel(frame: .zero)
    
    
    // MARK: - Private properties
    
    private let titleContentLayoutGuide = UILayoutGuide()
    
    private let titleLabelLayoutGuide = UILayoutGuide()
    
    private var titleImageInsetConstraint: NSLayoutConstraint!
    
    private var titleSubtitleSeparation: NSLayoutConstraint!
    
    private var subtitleDetailSeparation: NSLayoutConstraint!
    
    
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
        let imageView     = self.imageView
        let titleLabel    = self.titleLabel
        let subtitleLabel = self.subtitleLabel
        let detailLabel   = self.detailLabel
        
        imageView.translatesAutoresizingMaskIntoConstraints     = false
        titleLabel.translatesAutoresizingMaskIntoConstraints    = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints   = false
        
        titleLabel.isHidden    = true
        subtitleLabel.isHidden = true
        detailLabel.isHidden   = true
        imageView.isHidden     = true
        
        imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        
        let contentView = self.contentView
        contentView.addSubview(detailLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        contentView.addLayoutGuide(titleLabelLayoutGuide)
        contentView.addLayoutGuide(titleContentLayoutGuide)
        
        let width: CGFloat = bounds.width
        titleLabel.preferredMaxLayoutWidth    = width
        subtitleLabel.preferredMaxLayoutWidth = width
        detailLabel.preferredMaxLayoutWidth   = width
        
        if #available(iOS 10, *) {
            titleLabel.adjustsFontForContentSizeCategory    = true
            subtitleLabel.adjustsFontForContentSizeCategory = true
            detailLabel.adjustsFontForContentSizeCategory   = true
        }
        
        let defaultFonts = CollectionViewFormDetailCell.defaultFonts(compatibleWith: traitCollection)
        titleLabel.font    = defaultFonts.titleFont
        subtitleLabel.font = defaultFonts.subtitleFont
        detailLabel.font   = defaultFonts.detailFont
        
        detailLabel.numberOfLines = 2
        
        titleSubtitleSeparation  = NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel,    attribute: .bottom)
        subtitleDetailSeparation = NSLayoutConstraint(item: detailLabel,   attribute: .top, relatedBy: .equal, toItem: titleContentLayoutGuide, attribute: .bottom)
        titleImageInsetConstraint = NSLayoutConstraint(item: titleLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, constant: imageTextInset)
        
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleContentLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleContentLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleContentLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: titleLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: titleContentLayoutGuide, attribute: .leading, priority: UILayoutPriorityRequired - 1),
            NSLayoutConstraint(item: titleLabelLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: titleContentLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: titleLabelLayoutGuide, attribute: .centerY, relatedBy: .equal, toItem: titleContentLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: titleLabelLayoutGuide, attribute: .height, relatedBy: .lessThanOrEqual, toItem: titleContentLayoutGuide, attribute: .height),
            
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: titleContentLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: titleContentLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: titleContentLayoutGuide, attribute: .height),
            
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: titleLabelLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: titleLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: titleLabelLayoutGuide, attribute: .trailing),
            
            titleSubtitleSeparation,
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: titleLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: titleLabelLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom, relatedBy: .equal, toItem: titleLabelLayoutGuide, attribute: .bottom),
            
            subtitleDetailSeparation,
            NSLayoutConstraint(item: detailLabel, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: detailLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: detailLabel, attribute: .bottom,   relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .bottom),
        ])
        
        let textKeyPath     = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        titleLabel.addObserver(self,    forKeyPath: textKeyPath,     context: &kvoContext)
        titleLabel.addObserver(self,    forKeyPath: attrTextKeyPath, context: &kvoContext)
        subtitleLabel.addObserver(self, forKeyPath: textKeyPath,     context: &kvoContext)
        subtitleLabel.addObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        detailLabel.addObserver(self,   forKeyPath: textKeyPath,     context: &kvoContext)
        detailLabel.addObserver(self,   forKeyPath: attrTextKeyPath, context: &kvoContext)
        
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), options: [.new, .old], context: &kvoContext)
    }
    
    deinit {
        let textKeyPath     = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        titleLabel.removeObserver(self,    forKeyPath: textKeyPath,     context: &kvoContext)
        titleLabel.removeObserver(self,    forKeyPath: attrTextKeyPath, context: &kvoContext)
        subtitleLabel.removeObserver(self, forKeyPath: textKeyPath,     context: &kvoContext)
        subtitleLabel.removeObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        detailLabel.removeObserver(self,   forKeyPath: textKeyPath,     context: &kvoContext)
        detailLabel.removeObserver(self,   forKeyPath: attrTextKeyPath, context: &kvoContext)
        
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch object {
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
                
                let hasTitle    = (titleLabel.text?.isEmpty    ?? true) == false
                let hasSubtitle = (subtitleLabel.text?.isEmpty ?? true) == false
                let hasDetail   = (detailLabel.text?.isEmpty   ?? true) == false
                
                let titleSubtitleSeparationDistance = hasTitle && hasSubtitle ? CellTitleSubtitleSeparation : 0.0
                if titleSubtitleSeparationDistance !=~ titleSubtitleSeparation.constant {
                    titleSubtitleSeparation.constant = titleSubtitleSeparationDistance
                }
                
                let subtitleDetailSeparationDistance: CGFloat = (hasTitle || hasSubtitle) && hasDetail ? titleDetailSeparation : 0.0
                if subtitleDetailSeparationDistance !=~ subtitleDetailSeparation.constant {
                    subtitleDetailSeparation.constant = subtitleDetailSeparationDistance
                }
            case let imageView as UIImageView where imageView === self.imageView:
                
                let oldValue = change?[.oldKey] as? UIImage
                let newValue = change?[.newKey] as? UIImage
                
                if oldValue == newValue { return }
                
                let hasImage = imageView.image?.size.isEmpty ?? true == false
                
                updatePreferredMaxWidths()
                
                if imageView.isHidden != hasImage { return } // No toggling of visibility required
                
                imageView.isHidden = hasImage == false
                titleImageInsetConstraint.isActive = hasImage
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            let width = bounds.width
            if width !=~ oldValue.width {
                updatePreferredMaxWidths()
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            let width = bounds.width
            if width !=~ oldValue.width {
                updatePreferredMaxWidths()
            }
        }
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            if layoutMargins.left !=~ oldValue.left || layoutMargins.right !=~ oldValue.right {
                updatePreferredMaxWidths()
            }
        }
    }
    
    open override func contentSizeCategoryDidChange(_ newCategory: UIContentSizeCategory) {
        super.contentSizeCategoryDidChange(newCategory)
        
        if #available(iOS 10, *) { return }
        
        if let titleTextStyle = titleLabel.font?.textStyle {
            titleLabel.font = .preferredFont(forTextStyle: titleTextStyle)
        }
        if let subtitleTextStyle = subtitleLabel.font?.textStyle {
            subtitleLabel.font = .preferredFont(forTextStyle: subtitleTextStyle)
        }
        if let detailTextStyle = detailLabel.font?.textStyle {
            detailLabel.font = .preferredFont(forTextStyle: detailTextStyle)
        }
    }
    
    private func updatePreferredMaxWidths() {
        let layoutMargins = self.layoutMargins
        let width = bounds.width
        
        var contentWidth = width - layoutMargins.left - layoutMargins.right
        if let accessoryViewWidth = accessoryView?.frame.width {
            contentWidth -= accessoryViewWidth + 10.0
        }
        
        let titleWidth: CGFloat
        
        if let imageSize = imageView.image?.size, imageSize.isEmpty == false {
            titleWidth = contentWidth - imageSize.width - imageTextInset
        } else {
            titleWidth = contentWidth
        }
        
        titleLabel.preferredMaxLayoutWidth    = titleWidth
        subtitleLabel.preferredMaxLayoutWidth = titleWidth
        detailLabel.preferredMaxLayoutWidth   = contentWidth
    }
    
}
