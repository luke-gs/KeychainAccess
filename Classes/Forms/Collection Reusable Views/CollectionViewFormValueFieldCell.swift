//
//  CollectionViewFormValueFieldCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1


/// A value field cell within an MPOL Collection View.
///
/// Value fields represent items within a form like a text field, but
/// only present their data and allow interaction via popups and other
/// non-text based content input.
///
/// Though they look visually similar to subtitle cells, there are key
/// differences from subtitle cells.
/// 
/// From a content perspective, value field cells contain another label
/// behind their value for a placeholder. This label is baseline aligned
/// with the value label.
///
/// Value field cells also behave differently when their content updates.
/// When no value has been set, the value label does not collapse to move
/// the title label into the center. This allows the placeholder to stay
/// in place, and to sit beside other similar cells, like text field cells.
/// When the title label has no set text, however, the title label does
/// hide and the value label does center. This gives consistency with the
/// text field cell's behaviour, but it is recommended you should generally
/// always use titles with these cells.
///
/// If you want always-collapsing labels, it is recommended you use
/// subtitle cells.
open class CollectionViewFormValueFieldCell: CollectionViewFormCell {
    
    
    // MARK: - Public properties
    
    /// The text label for the cell.
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The value label for the cell.
    public let valueLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The placeholder label for the cell.
    public let placeholderLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The image view for the cell. This view is lazy loaded.
    open var imageView: UIImageView {
        if let existingImageView = _imageView { return existingImageView }
        
        let newImageView = UIImageView(frame: .zero)
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
    open var isEditable: Bool = true
    
    
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
    
    override open func commonInit() {
        super.commonInit()
        
        let titleLabel = self.titleLabel
        let valueLabel = self.valueLabel
        let placeholderLabel = self.placeholderLabel
        
        titleLabel.adjustsFontForContentSizeCategory = true
        valueLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.adjustsFontForContentSizeCategory = true
        
        titleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        valueLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        placeholderLabel.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        
        let contentView = self.contentView
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(titleLabel)
        
        _ = CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: "", value: "", inWidth: 300, compatibleWith: traitCollection)
        
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
        
        let maxContentSize = CGSize(width: contentRect.width, height: .greatestFiniteMagnitude)
        
        let titleSize = titleLabel.sizeThatFits(maxContentSize).constrained(to: maxContentSize)
        var valueSize = valueLabel.sizeThatFits(maxContentSize).constrained(to: maxContentSize)
        var placeholderSize = placeholderLabel.sizeThatFits(maxContentSize).constrained(to: maxContentSize)
        
        let valueFont = valueLabel.font!
        let placeholderFont = placeholderLabel.font!
        
        valueSize.height = max(valueSize.height, valueFont.lineHeight.ceiled(toScale: displayScale))
        placeholderSize.height = max(placeholderSize.height, placeholderFont.lineHeight.ceiled(toScale: displayScale))
        let labelSeparation = titleSize.isEmpty ? 0.0 : self.labelSeparation.ceiled(toScale: displayScale)
        
        
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
                                                      y: (centerYOfContent - (accessorySize.height / 2.0)).rounded(toScale: displayScale)),
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
            if let label = object as? UILabel {
                if keyPath == #keyPath(UILabel.isHidden) {
                    return // We don't need to relayout when labels hide - we ignore that.
                }
                if label == valueLabel && (keyPath == #keyPath(UILabel.text) || keyPath == #keyPath(UILabel.attributedText)) {
                    placeholderLabel.isHidden = (valueLabel.text?.isEmpty ?? true == false)
                }
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
    
    
    // MARK: - Class sizing methods
    
    
    /// Calculates the minimum content width for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - title:             The title details for sizing.
    ///   - value:             The value details for sizing.
    ///   - placeholder:       The placeholder details for sizing.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - imageSize:         The size for the image, to present, or `.zero`. The default is `.zero`.
    ///   - imageSeparation:   The image/label horizontal separation. The default is the standard separation.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: StringSizable?, value: StringSizable?, placeholder: StringSizable? = nil,
                                        compatibleWith traitCollection: UITraitCollection, imageSize: CGSize = .zero,
                                        imageSeparation: CGFloat = CellImageLabelSeparation, accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }
        
        var valueSizing = value?.sizing()
        if valueSizing != nil {
            if valueSizing!.font == nil {
                valueSizing!.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            }
            if valueSizing!.numberOfLines == nil {
                valueSizing!.numberOfLines = 1
            }
        }
        
        var placeholderSizing = placeholder?.sizing()
        if placeholderSizing != nil {
            if placeholderSizing!.font == nil {
                placeholderSizing!.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
            }
            if placeholderSizing!.numberOfLines == nil {
                placeholderSizing!.numberOfLines = 1
            }
        }
        
        let titleWidth = titleSizing?.minimumWidth(compatibleWith: traitCollection) ?? 0.0
        let valueWidth = valueSizing?.minimumWidth(compatibleWith: traitCollection) ?? 0.0
        let placeholderWidth = placeholderSizing?.minimumWidth(compatibleWith: traitCollection) ?? 0.0
        
        let imageSpace = imageSize.isEmpty ? 0.0 : imageSize.width + imageSeparation
        let accessorySpace = accessoryViewSize.isEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset
        
        return max(titleWidth, valueWidth, placeholderWidth) + imageSpace + accessorySpace
    }
    
    
    /// Calculates the minimum content height for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - title:             The title details for sizing.
    ///   - value:             The value details for sizing.
    ///   - placeholder:       The placeholder details for sizing.
    ///   - width:             The content width for the cell.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - imageSize:         The size for the image, to present, or `.zero`. The default is `.zero`.
    ///   - imageSeparation:   The image/label horizontal separation. The default is the standard separation.
    ///   - labelSeparation:   The label vertical separation. The default is the standard separation.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: StringSizable?, value: StringSizable?, placeholder: StringSizable? = nil,
                                         inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection, imageSize: CGSize = .zero,
                                         imageSeparation: CGFloat = CellImageLabelSeparation, labelSeparation: CGFloat = CellTitleSubtitleSeparation,
                                         accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }
        
        var valueSizing = value?.sizing() ?? StringSizing(string: "")
        if valueSizing.font == nil {
            valueSizing.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        }
        if valueSizing.numberOfLines == nil {
            valueSizing.numberOfLines = 0
        }
        
        var placeholderSizing = placeholder?.sizing()
        if placeholderSizing != nil {
            if placeholderSizing!.font == nil {
                placeholderSizing!.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
            }
            if placeholderSizing!.numberOfLines == nil {
                placeholderSizing!.numberOfLines = 0
            }
        }
        
        let isImageEmpty = imageSize.isEmpty
        let imageWidth = isImageEmpty ? 0.0 : imageSize.width + imageSeparation
        
        let isAccesssoryEmpty = accessoryViewSize.isEmpty
        
        let availableWidth = width - imageWidth - (isAccesssoryEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset)
        
        let titleHeight = titleSizing?.minimumHeight(inWidth: availableWidth, compatibleWith: traitCollection) ?? 0.0
        let valueHeight = valueSizing.minimumHeight(inWidth: availableWidth, allowingZeroHeight: false, compatibleWith: traitCollection)
        let placeholderHeight = placeholderSizing?.minimumHeight(inWidth: availableWidth, compatibleWith: traitCollection) ?? 0.0
        let separation = titleHeight >~ 0.0 ? labelSeparation : 0.0
        
        let combinedHeight = (titleHeight + max(valueHeight, placeholderHeight) + separation).ceiled(toScale: traitCollection.currentDisplayScale)
        
        return max(combinedHeight, (isImageEmpty ? 0.0 : imageSize.height), (isAccesssoryEmpty ? 0.0 : accessoryViewSize.height))
    }
    
}
