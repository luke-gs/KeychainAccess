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
    
    private class func standardFonts(compatibleWith traitCollection: UITraitCollection) -> (titleFont: UIFont, subtitleFont: UIFont) {
        return (.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection),
                .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection))
    }
    
    
    // MARK: - Public properties
    
    /// The text label for the cell.
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The subtitle label for the cell.
    public let subtitleLabel: UILabel = UILabel(frame: .zero)
    
    
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
    
    
    open var labelSeparation: CGFloat = CellTitleSubtitleSeparation {
        didSet {
            if labelSeparation !=~ oldValue {
                setNeedsLayout()
            }
        }
    }
    
    @available(*, deprecated, renamed: "labelSeparation", message: "This property has been renamed, and will be removed at a later date.")
    open var preferredLabelSeparation: CGFloat {
        get { return labelSeparation }
        set { labelSeparation = newValue }
    }
    
    
    // MARK: - Private/internal properties
    
    private var _imageView: UIImageView? {
        didSet {
            oldValue?.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
            _imageView?.addObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
        }
    }
    
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
        
        let titleLabel    = self.titleLabel
        let subtitleLabel = self.subtitleLabel
        
        titleLabel.isHidden    = true
        subtitleLabel.isHidden = true
        
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        
        let fonts = type(of: self).standardFonts(compatibleWith: traitCollection)
        titleLabel.font = fonts.titleFont
        subtitleLabel.font = fonts.subtitleFont
        
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
        _imageView?.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
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
            
            let inset = imageSize.width
            contentRect.size.width -= inset
            if isRightToLeft == false {
                contentRect.origin.x += inset
            }
        } else {
            imageSize = .zero
        }
        
        // work out label sizes
        var titleSize = titleLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        var subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        
        titleSize.width = min(contentRect.width, titleSize.width)
        subtitleSize.width = min(contentRect.width, subtitleSize.width)
        
        // Work out major content positions
        let labelSeparation = titleSize.isEmpty == false && subtitleSize.isEmpty == false ? self.labelSeparation : 0.0
        let heightForLabelContent = titleSize.height + subtitleSize.height + labelSeparation
        
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
        accessoryView?.frame = CGRect(origin: CGPoint(x: contentTrailingEdge - (isRightToLeft ? 0.0 : accessorySize.width),
                                                      y: (centerYOfContent - (accessorySize.height / 2.0)).rounded(toScale: displayScale)),
                                      size: accessorySize)
        
        // Position the labels
        var currentYOffset = (centerYOfContent - (heightForLabelContent / 2.0)).rounded(toScale: displayScale)
        
        titleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - titleSize.width : contentRect.minX, y: currentYOffset), size: titleSize)
        currentYOffset += (titleSize.height + labelSeparation).rounded(toScale: displayScale)
        
        let valueLabelFrame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - subtitleSize.width : contentRect.minX, y: currentYOffset), size: subtitleSize)
        subtitleLabel.frame = valueLabelFrame
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch object {
            case let label as UILabel where keyPath == #keyPath(UILabel.text) || keyPath == #keyPath(UILabel.attributedText):
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
    
    open override var accessibilityLabel: String? {
        get { return super.accessibilityLabel?.ifNotEmpty() ?? [titleLabel, subtitleLabel].flatMap({ $0.text }).joined(separator: ", ") }
        set { super.accessibilityLabel = newValue }
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - subtitle:           The subtitle text for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    ///   - image:              The leading image for the cell. The default is `nil`.
    ///   - titleFont:          The title font. The default is `nil`, indicating the calculation should use the default.
    ///   - subtitleFont:       The subtitle font. The default is `nil`, indicating the calculation should use the default.
    ///   - singleLineTitle:    A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineSubtitle: A boolean value indicating if the subtitle text should be constrained to a single line. The default is `false`.
    ///   - accessoryViewWidth: The width for the accessory view.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: String?, subtitle: String?, compatibleWith traitCollection: UITraitCollection,
                                        image: UIImage? = nil, titleFont: UIFont? = nil, subtitleFont: UIFont? = nil,
                                        singleLineTitle: Bool = true, singleLineSubtitle: Bool = false, accessoryViewWidth: CGFloat = 0.0) -> CGFloat {
        let standardFonts = self.standardFonts(compatibleWith: traitCollection)
        
        let titleTextFont = titleFont ?? standardFonts.titleFont
        let subtitleTextFont = subtitleFont ?? standardFonts.subtitleFont
        
        var imageSpace = image?.size.width ?? 0.0
        if imageSpace > 0.0 {
            imageSpace = ceil(imageSpace) + 16.0
        }
        
        let displayScale = traitCollection.currentDisplayScale
        
        let titleWidth = (title as NSString?)?.boundingRect(with: .max, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        let subtitleWidth = (subtitle as NSString?)?.boundingRect(with: .max, options: singleLineSubtitle ? [] : .usesLineFragmentOrigin,
                                                                  attributes: [NSFontAttributeName: subtitleTextFont],
                                                                  context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        return max(titleWidth, subtitleWidth) + imageSpace + (accessoryViewWidth > 0.00001 ? accessoryViewWidth + 10.0 : 0.0)
    }
    
    
    /// Calculates the minimum content height for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - subtitle:           The subtitle text for the cell.
    ///   - width:              The width constraint for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    ///   - image:              The leading image for the cell. The default is `nil`.
    ///   - titleFont:          The title font. The default is `nil`, indicating the calculation should use the default.
    ///   - subtitleFont:       The subtitle font. The default is `nil`, indicating the calculation should use the default.
    ///   - singleLineTitle:    A boolean value indicating if the title text should be constrained to a single line. The default is `false`.
    ///   - singleLineSubtitle: A boolean value indicating if the subtitle text should be constrained to a single line. The default is `false`.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: String?, subtitle: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         image: UIImage? = nil, titleFont: UIFont? = nil, subtitleFont: UIFont? = nil,
                                         singleLineTitle: Bool = true, singleLineSubtitle: Bool = false, labelSeparation: CGFloat = CellTitleSubtitleSeparation) -> CGFloat {
        let standardFonts = self.standardFonts(compatibleWith: traitCollection)
        
        let titleTextFont = titleFont ?? standardFonts.titleFont
        let subtitleTextFont = subtitleFont ?? standardFonts.subtitleFont
        
        let imageSize = image?.size
        
        
        let displayScale = traitCollection.currentDisplayScale
        
        let size = CGSize(width: imageSize == nil ? width : width - imageSize!.width - 16.0, height: CGFloat.greatestFiniteMagnitude)
        
        let titleHeight = (title as NSString?)?.boundingRect(with: size, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: titleTextFont],
                                                             context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        
        let subtitleHeight = (subtitle as NSString?)?.boundingRect(with: size, options: singleLineSubtitle ? [] : .usesLineFragmentOrigin,
                                                                   attributes: [NSFontAttributeName: subtitleTextFont],
                                                                   context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        var combinedHeight = titleHeight + subtitleHeight
        if titleHeight !=~ 0.0 && subtitleHeight !=~ 0.0 {
            combinedHeight += labelSeparation
        }
        
        return max(combinedHeight, (imageSize?.height ?? 0.0))
    }
    
}

