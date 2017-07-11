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
    public class func minimumContentHeight(withImageSize imageSize: CGSize? = nil, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let fonts = defaultFonts(compatibleWith: traitCollection)
        let displayScale = traitCollection.currentDisplayScale
        
        let titleFontHeight = fonts.titleFont.lineHeight.ceiled(toScale: displayScale) + fonts.subtitleFont.lineHeight.ceiled(toScale: displayScale) + CellTitleSubtitleSeparation.ceiled(toScale: displayScale)
        let titleImageHeight = max(titleFontHeight, imageSize?.height ?? 0.0)
        
        return titleImageHeight + ((fonts.detailFont.lineHeight * 2.0) + fonts.detailFont.leading).ceiled(toScale: displayScale) + titleDetailSeparation
    }
    
    private class func defaultFonts(compatibleWith traitCollection: UITraitCollection) -> (titleFont: UIFont, subtitleFont: UIFont, detailFont: UIFont) {
        return (.preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection),
                .preferredFont(forTextStyle: .footnote,    compatibleWith: traitCollection),
                .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection))
    }
    
    
    // MARK: - Public properties
    
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    public let subtitleLabel: UILabel = UILabel(frame: .zero)
    
    public let detailLabel: UILabel = UILabel(frame: .zero)
    
    /// The image view for the cell. This view is lazy loaded.
    public var imageView: UIImageView {
        if let existingImageView = _imageView { return existingImageView }
        
        let newImageView = UIImageView(frame: .zero)
        newImageView.isHidden = true
        contentView.addSubview(newImageView)
        
        _imageView = newImageView
        setNeedsLayout()
        
        return newImageView
    }
    
    
    // MARK: - Private properties
    
    private var _imageView: UIImageView? {
        didSet {
            keyPathsAffectingImageViewLayout.forEach {
                oldValue?.removeObserver(self, forKeyPath: $0, context: &kvoContext)
                _imageView?.addObserver(self, forKeyPath: $0, context: &kvoContext)
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
        let titleLabel    = self.titleLabel
        let subtitleLabel = self.subtitleLabel
        let detailLabel   = self.detailLabel
        
        titleLabel.isHidden    = true
        subtitleLabel.isHidden = true
        detailLabel.isHidden   = true
        
        titleLabel.adjustsFontForContentSizeCategory    = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        detailLabel.adjustsFontForContentSizeCategory   = true
        
        let defaultFonts = CollectionViewFormDetailCell.defaultFonts(compatibleWith: traitCollection)
        titleLabel.font    = defaultFonts.titleFont
        subtitleLabel.font = defaultFonts.subtitleFont
        detailLabel.font   = defaultFonts.detailFont
        
        detailLabel.numberOfLines = 2
        
        let contentView = self.contentView
        contentView.addSubview(detailLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
            subtitleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
            detailLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
        }
    }
    
    deinit {
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            subtitleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            detailLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
        }
        if let imageView = _imageView {
            keyPathsAffectingImageViewLayout.forEach {
                imageView.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            }
        }
    }
    
    
    // MARK: - Overrides
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentView = self.contentView
        let displayScale = traitCollection.currentDisplayScale
        let isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        var contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        
        // Calculate sizes
        let imageSize: CGSize
        let imageInset: CGFloat
        let accessorySize: CGSize
        
        if let size = self.accessoryView?.frame.size, size.isEmpty == false {
            accessorySize = size
            let inset = size.width + 10.0
            contentRect.size.width -= inset
            
            if isRightToLeft {
                contentRect.origin.x += inset
            }
        } else {
            accessorySize = .zero
        }
        
        if let imageViewSize = _imageView?.intrinsicContentSize, imageViewSize.isEmpty == false {
            imageSize = imageView.intrinsicContentSize
            imageInset = imageSize.isEmpty ? 0.0 : imageSize.width + imageTextInset.ceiled(toScale: displayScale)
        } else {
            imageSize = .zero
            imageInset = 0.0
        }
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: contentRect.width - imageInset, height: .greatestFiniteMagnitude))
        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: contentRect.width - imageInset, height: .greatestFiniteMagnitude))
        let detailSize = detailLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        
        let titleLabelContentHeight = titleSize.height + subtitleSize.height + (titleSize.isEmpty == false && subtitleSize.isEmpty == false ? CellTitleSubtitleSeparation.ceiled(toScale: displayScale) : 0.0)
        let titleContentHeight = max(titleLabelContentHeight, imageSize.height)
        let totalContentHeight = max(detailSize.height + titleContentHeight + (detailSize.height >~ 0.0 && titleContentHeight >~ 0.0 ? titleDetailSeparation : 0.0), accessorySize.height)
        
        let contentYOrigin: CGFloat
        switch contentMode {
        case .top, .topLeft, .topRight:
            contentYOrigin = contentRect.minY
        case .bottom, .bottomLeft, .bottomRight:
            contentYOrigin = max(contentRect.minY, contentRect.maxY - totalContentHeight)
        default:
            contentYOrigin = max(contentRect.minY, contentRect.midY - totalContentHeight / 2.0)
        }
        
        // Update accessory positions
        
        _imageView?.frame = CGRect(origin: CGPoint(x: isRightToLeft ? (contentRect.maxX - imageSize.width).ceiled(toScale: displayScale): contentRect.minX,
                                                   y: (contentYOrigin + (titleContentHeight - imageSize.height) / 2.0).rounded(toScale: displayScale)),
                                   size: imageSize)
        accessoryView?.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.minX : (contentRect.maxX - accessorySize.width).floored(toScale: displayScale),
                                                      y: (contentYOrigin - (totalContentHeight / 2.0)).rounded(toScale: displayScale)),
                                      size: accessorySize)
        
        
        // Update label frames
        let titleFrame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - imageInset - titleSize.width : contentRect.minX + imageInset,
                                                y: (contentYOrigin + (titleContentHeight - titleLabelContentHeight) / 2.0).rounded(toScale: displayScale)),
                                size: titleSize)
        titleLabel.frame = titleFrame
        subtitleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - imageInset - subtitleSize.width : contentRect.minX + imageInset,
                                                   y: titleFrame.maxY + CellTitleSubtitleSeparation.ceiled(toScale: displayScale)), size: subtitleSize)
        
        detailLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - detailSize.width : contentRect.minX,
                                                   y: contentYOrigin + titleContentHeight + titleDetailSeparation.rounded(toScale: displayScale)),
                                   size: detailSize)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch object {
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
            case let imageView as UIImageView:
                imageView.isHidden = imageView.intrinsicContentSize.isEmpty
            default:
                break
            }
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}

