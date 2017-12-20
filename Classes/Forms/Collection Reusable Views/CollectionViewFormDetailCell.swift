//
//  CollectionViewFormDetailCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


fileprivate var kvoContext = 1

fileprivate let titleDetailSeparation: CGFloat = 7.0


open class CollectionViewFormDetailCell: CollectionViewFormCell {
    
    
    /// Calculates a minimum height with the standard configuration of single lines
    /// for the title and subtitle, and a double line for detail text unless detail sizable
    /// has number of lines specified.
    ///
    /// - Parameter
    ///   - detail: The detail sizable information.
    ///   - image: An optional size for an image to display at the leading edge of the titles.
    ///   - width: The available width.
    ///   - traitCollection: The trait collection.
    /// - Returns: The correct height for the cell.
    public class func minimumContentHeight(withTitle title: StringSizable?, subtitle: StringSizable?, detail: StringSizable?, imageSize: CGSize? = nil, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let fonts = defaultFonts(compatibleWith: traitCollection)
        let displayScale = traitCollection.currentDisplayScale
        
        let titleSizing = title?.sizing(defaultNumberOfLines: 1, defaultFont: fonts.titleFont)
        let titleHeight = titleSizing?.minimumHeight(inWidth: width, compatibleWith: traitCollection) ?? 0.0
    
        let subtitleSizing = subtitle?.sizing(defaultNumberOfLines: 1, defaultFont: fonts.subtitleFont)
        let subtitleHeight = subtitleSizing?.minimumHeight(inWidth: width, compatibleWith: traitCollection) ?? 0.0
        
        let titleSubtitleHeight = titleHeight + subtitleHeight + CellTitleSubtitleSeparation.ceiled(toScale: displayScale)
        let titleImageHeight = max(titleSubtitleHeight, imageSize?.height ?? 0.0)
        
        let imageInset = (imageSize?.isEmpty).isTrue ? 0.0 : (imageSize?.width ?? 0.0) + CellImageLabelSeparation.ceiled(toScale: displayScale)
        let detailSizing = detail?.sizing(defaultNumberOfLines: 0, defaultFont: fonts.detailFont)
        let detailHeight = detailSizing?.minimumHeight(inWidth: width - imageInset, compatibleWith: traitCollection) ?? 0.0

        return titleImageHeight + (detailHeight + fonts.detailFont.leading).ceiled(toScale: displayScale) + titleDetailSeparation
    }
    
    public class func defaultFonts(compatibleWith traitCollection: UITraitCollection) -> (titleFont: UIFont, subtitleFont: UIFont, detailFont: UIFont) {
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
    
    override open func commonInit() {
        super.commonInit()

        contentMode = .top

        let titleLabel    = self.titleLabel
        let subtitleLabel = self.subtitleLabel
        let detailLabel   = self.detailLabel
        
        titleLabel.adjustsFontForContentSizeCategory    = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        detailLabel.adjustsFontForContentSizeCategory   = true
        
        let defaultFonts = CollectionViewFormDetailCell.defaultFonts(compatibleWith: traitCollection)
        titleLabel.font    = defaultFonts.titleFont
        subtitleLabel.font = defaultFonts.subtitleFont
        detailLabel.font   = defaultFonts.detailFont
        
        titleLabel.numberOfLines = 1
        titleLabel.numberOfLines = 1
        detailLabel.numberOfLines = 0
        
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
            let inset = size.width + CollectionViewFormCell.accessoryContentInset
            contentRect.size.width -= inset
            
            if isRightToLeft {
                contentRect.origin.x += inset
            }
        } else {
            accessorySize = .zero
        }
        
        if let imageViewSize = _imageView?.intrinsicContentSize, imageViewSize.isEmpty == false {
            imageSize = imageViewSize
            imageInset = imageViewSize.isEmpty || imageView.isHidden ? 0.0 : imageSize.width + CellImageLabelSeparation.ceiled(toScale: displayScale)
        } else {
            imageSize = .zero
            imageInset = 0.0
        }

        let widthMinusInset = contentRect.width - imageInset

        let titleSize    = titleLabel.sizeThatFits(CGSize(width: widthMinusInset, height: .greatestFiniteMagnitude))
        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: widthMinusInset, height: .greatestFiniteMagnitude))
        let detailSize   = detailLabel.sizeThatFits(CGSize(width: widthMinusInset, height: .greatestFiniteMagnitude))
        
        let showingTitle    = titleSize.isEmpty == false && titleLabel.isHidden == false
        let showingSubtitle = subtitleSize.isEmpty == false && subtitleLabel.isHidden == false
        let showingDetail   = detailSize.isEmpty == false && detailLabel.isHidden == false
        
        let titleLabelContentHeight = (showingTitle ? titleSize.height : 0.0) + (showingSubtitle ? subtitleSize.height : 0.0) + (showingTitle && showingDetail ? CellTitleSubtitleSeparation.ceiled(toScale: displayScale) : 0.0)
        let titleContentHeight = max(titleLabelContentHeight, (imageInset ==~ 0.0 ? 0.0 : imageSize.height))
        let totalContentHeight = max((showingDetail ? detailSize.height : 0.0) + titleContentHeight + (showingDetail && titleContentHeight >~ 0.0 ? titleDetailSeparation : 0.0), accessorySize.height)
        
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
        accessoryView?.frame = CGRect(origin: CGPoint(x: (isRightToLeft ? contentRect.minX - accessorySize.width - CollectionViewFormCell.accessoryContentInset : contentRect.maxX + CollectionViewFormCell.accessoryContentInset).floored(toScale: displayScale),
                                                      y: (contentYOrigin + ((totalContentHeight - accessorySize.height) / 2.0)).rounded(toScale: displayScale)),
                                      size: accessorySize)
        
        
        // Update label frames
        let titleFrame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - imageInset - titleSize.width : contentRect.minX + imageInset,
                                                y: (contentYOrigin + (titleContentHeight - titleLabelContentHeight) / 2.0).rounded(toScale: displayScale)),
                                size: titleSize)
        titleLabel.frame = titleFrame
        subtitleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - imageInset - subtitleSize.width : contentRect.minX + imageInset,
                                                     y: (showingTitle ? titleFrame.maxY + CellTitleSubtitleSeparation.ceiled(toScale: displayScale) : titleFrame.minY)),
                                     size: subtitleSize)
        
        detailLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - imageInset - detailSize.width : contentRect.minX + imageInset,
                                                   y: contentYOrigin + titleContentHeight + (titleContentHeight >~ 0.0 ? titleDetailSeparation.rounded(toScale: displayScale) : 0.0)),
                                   size: detailSize)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}

