//
//  CollectionViewFormSubtitleCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

open class CollectionViewFormSubtitleCell: CollectionViewFormCell {
    
    // MARK: - Public properties
    
    /// The text label for the cell.
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The subtitle label for the cell.
    public let subtitleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The image view for the cell. This view is lazy loaded.
    public var imageView: UIImageView {
        if let existingImageView = _imageView { return existingImageView }
        
        let newImageView = UIImageView(frame: .zero)
        contentView.addSubview(newImageView)
        
        _imageView = newImageView
        setNeedsLayout()
        
        return newImageView
    }
    
    /// The horizontal separation between the image and the labels.
    ///
    /// The default is the default MPOL image separation.
    open var imageSeparation: CGFloat = CellImageLabelSeparation {
        didSet {
            if imageSeparation !=~ oldValue && _imageView != nil {
                setNeedsLayout()
            }
        }
    }
    
    /// The vertical separation between labels.
    ///
    /// The default is the default MPOL Title-Subtitle separation.
    open var labelSeparation: CGFloat = CellTitleSubtitleSeparation {
        didSet {
            if labelSeparation !=~ oldValue {
                setNeedsLayout()
            }
        }
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
    
    
    // MARK: - Initialization
    
    override func commonInit() {
        super.commonInit()
        
        let titleLabel = self.titleLabel
        let subtitleLabel = self.subtitleLabel
        
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        
        let contentView = self.contentView
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        
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
        let contentLeadingEdge = isRightToLeft ? contentRect.maxX : contentRect.minX
        let contentTrailingEdge = isRightToLeft ? contentRect.minX : contentRect.maxX
        
        var imageSize: CGSize
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
            imageSize = imageView.intrinsicContentSize
            
            if _imageView!.isHidden == false {
                let inset = imageSize.width + imageSeparation
                contentRect.size.width -= inset
                if isRightToLeft == false {
                    contentRect.origin.x += inset
                }
            }
        } else {
            imageSize = .zero
        }
        
        // work out label sizes
        let maxTextSize = CGSize(width: contentRect.width, height: .greatestFiniteMagnitude)
        
        let titleSize    = titleLabel.sizeThatFits(maxTextSize).constrained(to: maxTextSize)
        let subtitleSize = subtitleLabel.sizeThatFits(maxTextSize).constrained(to: maxTextSize)
        
        let titleVisible = titleSize.isEmpty == false && titleLabel.isHidden == false
        let subtitleVisible = subtitleSize.isEmpty == false && titleLabel.isHidden == false
        
        // Work out major content positions
        let labelSeparation = titleVisible && subtitleVisible ? self.labelSeparation : 0.0
        let heightForLabelContent = (titleVisible ? titleSize.height : 0.0) + (subtitleVisible ? subtitleSize.height : 0) + labelSeparation
        
        let centerYOfContent: CGFloat
        
        let halfContent = max(heightForLabelContent, imageSize.height, accessorySize.height) / 2.0
        let minimumContentCenterY = contentRect.minY + halfContent
        switch contentMode {
        case .bottom, .bottomLeft, .bottomRight:
            centerYOfContent = max(minimumContentCenterY, contentRect.maxY - halfContent)
        case .top, .topLeft, .topRight:
            centerYOfContent = minimumContentCenterY
        default:
            centerYOfContent = max(minimumContentCenterY, contentRect.midY)
        }
        
        // Position the side views
        
        _imageView?.frame = CGRect(origin: CGPoint(x: contentLeadingEdge - (isRightToLeft ? imageSize.width : 0.0),
                                                   y: (centerYOfContent - (imageSize.height / 2.0)).rounded(toScale: displayScale)),
                                   size: imageSize)
        let accessoryViewFrame = CGRect(origin: CGPoint(x: contentTrailingEdge - (isRightToLeft ? 0.0 : accessorySize.width),
                                                        y: (centerYOfContent - (accessorySize.height / 2.0)).rounded(toScale: displayScale)),
                                        size: accessorySize)
        
        accessoryView?.frame = accessoryViewFrame
        
        // Position the labels
        var currentYOffset = (centerYOfContent - (heightForLabelContent / 2.0)).rounded(toScale: displayScale)
        
        titleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - titleSize.width : contentRect.minX, y: currentYOffset), size: titleSize)
        if titleVisible {
            currentYOffset += (titleSize.height + labelSeparation).rounded(toScale: displayScale)
        }
        
        let valueLabelFrame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - subtitleSize.width : contentRect.minX, y: currentYOffset), size: subtitleSize)
        subtitleLabel.frame = valueLabelFrame
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override var accessibilityLabel: String? {
        get { return super.accessibilityLabel?.ifNotEmpty() ?? [titleLabel, subtitleLabel].flatMap({ $0.text }).joined(separator: ", ") }
        set { super.accessibilityLabel = newValue }
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content width for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - title:             The title details for sizing.
    ///   - subtitle:          The subtitle details for sizing.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - imageSize:         The size for the image, to present, or `.zero`. The default is `.zero`.
    ///   - imageSeparation:   The image/label horizontal separation. The default is the standard separation.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: StringSizable?, subtitle: StringSizable?, compatibleWith traitCollection: UITraitCollection,
                                        imageSize: CGSize = .zero, imageSeparation: CGFloat = CellImageLabelSeparation, accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }
        
        var subtitleSizing = subtitle?.sizing()
        if subtitleSizing != nil {
            if subtitleSizing!.font == nil {
                subtitleSizing!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            }
            if subtitleSizing!.numberOfLines == nil {
                subtitleSizing!.numberOfLines = 1
            }
        }
        
        
        let titleWidth = titleSizing?.minimumWidth(compatibleWith: traitCollection) ?? 0.0
        let valueWidth = subtitleSizing?.minimumWidth(compatibleWith: traitCollection) ?? 0.0
        
        let imageSpace = imageSize.isEmpty ? 0.0 : imageSize.width + imageSeparation
        let accessorySpace = accessoryViewSize.isEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset
        
        return max(titleWidth, valueWidth) + imageSpace + accessorySpace
    }
    
    
    /// Calculates the minimum content height for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - title:             The title details for sizing.
    ///   - subtitle:          The subtitle details for sizing.
    ///   - width:             The content width for the cell.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - imageSize:         The size for the image, to present, or `.zero`. The default is `.zero`.
    ///   - imageSeparation:   The image/label horizontal separation. The default is the standard separation.
    ///   - labelSeparation:   The label vertical separation. The default is the standard separation.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: StringSizable?, subtitle: StringSizable?, inWidth width: CGFloat,
                                         compatibleWith traitCollection: UITraitCollection, imageSize: CGSize = .zero,
                                         imageSeparation: CGFloat = CellImageLabelSeparation, labelSeparation: CGFloat = CellTitleSubtitleSeparation,
                                         accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }
        
        var subtitleSizing = subtitle?.sizing()
        if subtitleSizing != nil {
            if subtitleSizing!.font == nil {
                subtitleSizing!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            }
            if subtitleSizing!.numberOfLines == nil {
                subtitleSizing!.numberOfLines = 1
            }
        }
        
        let isImageEmpty = imageSize.isEmpty
        let imageWidth = isImageEmpty ? 0.0 : imageSize.width + imageSeparation
        
        let isAccesssoryEmpty = accessoryViewSize.isEmpty
        
        let availableWidth = width - imageWidth - (isAccesssoryEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset)
        
        let titleHeight = titleSizing?.minimumHeight(inWidth: availableWidth, compatibleWith: traitCollection) ?? 0.0
        let valueHeight = subtitleSizing?.minimumHeight(inWidth: availableWidth, compatibleWith: traitCollection) ?? 0.0
        let separation = titleHeight >~ 0.0 && valueHeight >~ 0.0 ? labelSeparation : 0.0
        
        let combinedHeight = (titleHeight + valueHeight + separation).ceiled(toScale: traitCollection.currentDisplayScale)
        
        return max(combinedHeight, (isImageEmpty ? 0.0 : imageSize.height), (isAccesssoryEmpty ? 0.0 : accessoryViewSize.height))
    }
    
}

