//
//  CollectionViewFormValueFieldCell.swift
//  Pods
//
//  Created by Rod Brown on 28/5/17.
//
//

import UIKit

fileprivate var kvoContext = 1

open class CollectionViewFormValueFieldCell: CollectionViewFormCell {
    
    private class func standardFonts(compatibleWith traitCollection: UITraitCollection) -> (titleFont: UIFont, valueFont: UIFont) {
        return (.preferredFont(forTextStyle: .footnote),
                .preferredFont(forTextStyle: .headline))
    }
    
    // MARK: - Public properties
    
    /// The text label for the cell.
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The value label for the cell.
    public let valueLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The placeholder label for the cell.
    public let placeholderLabel: UILabel = UILabel(frame: .zero)
    
    
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
    
    
    /// A boolean value indicating whether the cell represents an editable field.
    /// The default is `true`.
    ///
    /// This value informs MPOLKit view controllers and apps that the cell should be
    /// displayed with the standard MPOL editable colors and/or adornments.
    public var isEditable: Bool = true
    
    
    
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
        
        let titleLabel       = self.titleLabel
        let valueLabel       = self.valueLabel
        let placeholderLabel = self.placeholderLabel
        
        titleLabel.isHidden = true
        valueLabel.isHidden = true
        placeholderLabel.isHidden = true
        
        titleLabel.adjustsFontForContentSizeCategory = true
        valueLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.adjustsFontForContentSizeCategory = true
        
        let fonts = type(of: self).standardFonts(compatibleWith: traitCollection)
        titleLabel.font = fonts.titleFont
        valueLabel.font = fonts.valueFont
        placeholderLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        let contentView = self.contentView
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(titleLabel)
        
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
            valueLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
            placeholderLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
        }
    }
    
    deinit {
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            valueLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            placeholderLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
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
        
        let imageSize: CGSize
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
        var valueSize = valueLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        var placeholderSize = placeholderLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        
        let valueFont = valueLabel.font!
        let placeholderFont = placeholderLabel.font!
        
        titleSize.height = max(titleSize.height, titleLabel.font.lineHeight.ceiled(toScale: displayScale))
        valueSize.height = max(valueSize.height, valueFont.lineHeight.ceiled(toScale: displayScale))
        placeholderSize.height = max(placeholderSize.height, placeholderFont.lineHeight.ceiled(toScale: displayScale))
        
        titleSize.width = min(contentRect.width, titleSize.width)
        valueSize.width = min(contentRect.width, valueSize.width)
        placeholderSize.width = min(contentRect.width, placeholderSize.width)
        
        // Work out major content positions
        let heightForLabelContent = titleSize.height + valueSize.height + labelSeparation
        
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
                                                      y: (centerYOfContent + (accessorySize.height / 2.0)).rounded(toScale: displayScale)),
                                      size: accessorySize)
        
        // Position the labels
        var currentYOffset = (centerYOfContent - (heightForLabelContent / 2.0)).rounded(toScale: displayScale)
        
        titleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - titleSize.width : contentRect.minX, y: currentYOffset), size: titleSize)
        currentYOffset += (titleSize.height + labelSeparation).rounded(toScale: displayScale)
        
        let valueLabelFrame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - valueSize.width : contentRect.minX, y: currentYOffset), size: valueSize)
        valueLabel.frame = valueLabelFrame
        
        // Work out the baseline adjustment to keep these two labels together.
        let placeholderYLocation = (valueLabelFrame.minY + valueFont.ascender - placeholderFont.ascender).floored(toScale: displayScale)
        
        placeholderLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - placeholderSize.width : contentRect.minX, y: placeholderYLocation), size: placeholderSize)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch object {
            case let label as UILabel where keyPath == #keyPath(UILabel.text) || keyPath == #keyPath(UILabel.attributedText):
                updateLabelHiddenState(label)
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
        get { return super.accessibilityLabel?.ifNotEmpty() ?? [titleLabel, valueLabel].flatMap({ $0.text }).joined(separator: ", ") }
        set { super.accessibilityLabel = newValue }
    }
    
    
    // MARK: - Private methods
    
    private func updateLabelHiddenState(_ label: UILabel) {
        if label == titleLabel {
            titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
            return
        }
        
        let valueEmpty = valueLabel.text?.isEmpty ?? true
        valueLabel.isHidden = valueEmpty
        placeholderLabel.isHidden = placeholderLabel.text?.isEmpty ?? true || valueEmpty == false
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - value:              The value text for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    ///   - image:              The leading image for the cell. The default is `nil`.
    ///   - titleFont:          The title font. The default is `nil`, indicating the calculation should use the default.
    ///   - valueFont:          The value font. The default is `nil`, indicating the calculation should use the default.
    ///   - singleLineTitle:    A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineValue:    A boolean value indicating if the value text should be constrained to a single line. The default is `true`.
    ///   - accessoryViewWidth: The width for the accessory view.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: String?, value: String?, compatibleWith traitCollection: UITraitCollection,
                                        image: UIImage? = nil, titleFont: UIFont? = nil, valueFont: UIFont? = nil,
                                        singleLineTitle: Bool = true, singleLineValue: Bool = true, accessoryViewWidth: CGFloat = 0.0) -> CGFloat {
        let standardFonts = self.standardFonts(compatibleWith: traitCollection)
        
        let titleTextFont = titleFont ?? standardFonts.titleFont
        let valueTextFont = valueFont ?? standardFonts.valueFont
        
        var imageSpace = image?.size.width ?? 0.0
        if imageSpace > 0.0 {
            imageSpace = ceil(imageSpace) + 16.0
        }
        
        let displayScale = traitCollection.currentDisplayScale
        
        let titleWidth = (title as NSString?)?.boundingRect(with: .max, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        let valueWidth = (value as NSString?)?.boundingRect(with: .max, options: singleLineValue ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: valueTextFont],
                                                            context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        return max(titleWidth, valueWidth) + imageSpace + (accessoryViewWidth >~ 0.0 ? accessoryViewWidth + 10.0 : 0.0)
    }
    
    
    /// Calculates the minimum content height for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:           The title text for the cell.
    ///   - value:           The value text for the cell.
    ///   - width:           The width constraint for the cell.
    ///   - traitCollection: The trait collection the cell will be displayed in.
    ///   - image:           The leading image for the cell. The default is `nil`.
    ///   - titleFont:       The title font. The default is `nil`, indicating the calculation should use the default.
    ///   - valueFont:       The value font. The default is `nil`, indicating the calculation should use the default.
    ///   - singleLineTitle: A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineValue: A boolean value indicating if the value text should be constrained to a single line. The default is `true`.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: String?, value: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         image: UIImage? = nil, titleFont: UIFont? = nil, valueFont: UIFont? = nil, singleLineTitle: Bool = true,
                                         singleLineValue: Bool = true, labelSeparation: CGFloat = CellTitleSubtitleSeparation) -> CGFloat {
        let standardFonts = self.standardFonts(compatibleWith: traitCollection)
        
        let titleTextFont = titleFont ?? standardFonts.titleFont
        let valueTextFont = valueFont ?? standardFonts.valueFont
        
        let imageSize = image?.size
        
        let displayScale = traitCollection.currentDisplayScale
        
        let size = CGSize(width: imageSize == nil ? width : width - imageSize!.width - 16.0, height: CGFloat.greatestFiniteMagnitude)
        
        let titleHeight = (title as NSString?)?.boundingRect(with: size, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: titleTextFont],
                                                             context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        
        let valueHeight = (value as NSString?)?.boundingRect(with: size, options: singleLineValue ? [] : .usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: valueTextFont],
                                                             context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        let combinedHeight = titleHeight + valueHeight + labelSeparation
        
        return max(combinedHeight, (imageSize?.height ?? 0.0))
    }
}
