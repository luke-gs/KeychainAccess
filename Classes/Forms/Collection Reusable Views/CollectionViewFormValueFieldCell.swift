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
        if #available(iOS 10, *) {
            return (UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection), UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection))
        } else {
            return (UIFont.preferredFont(forTextStyle: .footnote), UIFont.preferredFont(forTextStyle: .headline))
        }
    }
    
    // MARK: - Public properties
    
    /// The text label for the cell.
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The value label for the cell.
    public let valueLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The placeholder label for the cell.
    public let placeholderLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The image view for the cell.
    public let imageView: UIImageView = UIImageView(frame: .zero)
    
    
    /// A boolean value indicating whether the cell represents an editable field.
    /// The default is `true`.
    ///
    /// This value can be used to inform MPOL apps that the cell should be
    /// displayed with the standard MPOL editable colors and/or adornments.
    public var isEditable: Bool = true
    
    
    open var preferredLabelSeparation: CGFloat = CellTitleSubtitleSeparation {
        didSet {
            if preferredLabelSeparation !=~ oldValue {
                titleValueConstraint.constant = preferredLabelSeparation
            }
        }
    }
    
    
    // MARK: - Private/internal properties
    
    internal let textLayoutGuide = UILayoutGuide()
    
    private var titleValueConstraint: NSLayoutConstraint!
    
    private var textLeadingConstraint: NSLayoutConstraint!
    
    private var valueHeightConstraint: NSLayoutConstraint!
    
    
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
        
        let contentView      = self.contentView
        let titleLabel       = self.titleLabel
        let valueLabel       = self.valueLabel
        let placeholderLabel = self.placeholderLabel
        let imageView        = self.imageView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        
        let textLayoutGuide        = self.textLayoutGuide
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        contentView.addLayoutGuide(textLayoutGuide)
        
        imageView.isHidden = true
        titleLabel.isHidden = true
        valueLabel.isHidden = true
        placeholderLabel.isHidden = true
        
        if #available(iOS 10, *) {
            titleLabel.adjustsFontForContentSizeCategory = true
            valueLabel.adjustsFontForContentSizeCategory = true
            placeholderLabel.adjustsFontForContentSizeCategory = true
        }
        
        let fonts = type(of: self).standardFonts(compatibleWith: traitCollection)
        titleLabel.font = fonts.titleFont
        valueLabel.font = fonts.valueFont
        placeholderLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        valueLabel.numberOfLines = 0
        
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh + 1, for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh + 1, for: .horizontal)
        
        titleValueConstraint  = NSLayoutConstraint(item: valueLabel,   attribute: .top,      relatedBy: .equal, toItem: titleLabel, attribute: .bottom, constant: preferredLabelSeparation)
        textLeadingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .leading,  relatedBy: .equal, toItem: imageView, attribute: .trailing)
        valueHeightConstraint = NSLayoutConstraint(item: valueLabel,   attribute: .height,   relatedBy: .greaterThanOrEqual, toConstant: valueLabel.font!.lineHeight.ceiled(toScale: traitCollection.currentDisplayScale))
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: valueLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: valueLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: valueLabel, attribute: .bottom,   relatedBy: .equal,           toItem: textLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: placeholderLabel, attribute: .firstBaseline, relatedBy: .equal, toItem: valueLabel, attribute: .firstBaseline),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual,   toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading, priority: UILayoutPriorityDefaultHigh),
            
            textLeadingConstraint,
            titleValueConstraint,
            valueHeightConstraint,
            
            NSLayoutConstraint(item: imageView,       attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow)
            ])
        
        let textKeyPath = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        
        titleLabel.addObserver(self, forKeyPath: textKeyPath, context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        valueLabel.addObserver(self, forKeyPath: textKeyPath, context: &kvoContext)
        valueLabel.addObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        valueLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        placeholderLabel.addObserver(self, forKeyPath: textKeyPath, context: &kvoContext)
        placeholderLabel.addObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
    }
    
    deinit {
        let textKeyPath     = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        
        titleLabel.removeObserver(self, forKeyPath: textKeyPath, context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        valueLabel.removeObserver(self, forKeyPath: textKeyPath, context: &kvoContext)
        valueLabel.removeObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        valueLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        placeholderLabel.removeObserver(self, forKeyPath: textKeyPath, context: &kvoContext)
        placeholderLabel.removeObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch object {
            case let label as UILabel:
                if keyPath == #keyPath(UILabel.font) {
                    updateValueHeightConstraint()
                } else {
                    updateLabelHiddenState(label)
                }
            case let imageView as UIImageView:
                let noImage = imageView.image?.size.isEmpty ?? true
                imageView.isHidden = false
                textLeadingConstraint.constant = noImage ? 0.0 : 16.0
                updateLabelMaxSizes()
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            if bounds.width !=~ oldValue.width {
                updateLabelMaxSizes()
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if frame.width !=~ oldValue.width {
                updateLabelMaxSizes()
            }
        }
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            let layoutMargins = self.layoutMargins
            if layoutMargins.left !=~ oldValue.left || layoutMargins.right !=~ oldValue.right {
                updateLabelMaxSizes()
            }
        }
    }
    
    open override var accessoryView: UIView? {
        didSet {
            updateLabelMaxSizes()
        }
    }
    
    open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return [titleLabel, valueLabel].flatMap({ $0.text }).joined(separator: ", ")
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.currentDisplayScale ?? UIScreen.main.scale != traitCollection.currentDisplayScale {
            if #available(iOS 10, *), previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory, valueLabel.adjustsFontForContentSizeCategory {
                // This will get handled by that content side category change.
                return
            }
            
            updateValueHeightConstraint()
        }
    }
    
    open override func contentSizeCategoryDidChange(_ newCategory: UIContentSizeCategory) {
        super.contentSizeCategoryDidChange(newCategory)
        
        if #available(iOS 10, *) {
            if valueLabel.adjustsFontForContentSizeCategory {
                // adjustsFontForContentSizeCategory doesn't fire KVO. We need to call the update ourselves.
                updateValueHeightConstraint()
            }
            return
        }
        
        titleLabel.legacy_adjustFontForContentSizeCategoryChange()
        valueLabel.legacy_adjustFontForContentSizeCategoryChange()
        placeholderLabel.legacy_adjustFontForContentSizeCategoryChange()
    }
    
    
    // MARK: - Private methods
    
    private func updateLabelMaxSizes() {
        let width         = frame.width
        let layoutMargins = self.layoutMargins
        let accessoryViewWidth = accessoryView?.bounds.width ?? 0.0
        let imageViewWidth = imageView.image?.size.width ?? 0.0
        
        let allowedTextWidth = width - layoutMargins.left - layoutMargins.right - (accessoryViewWidth > 0.0 ? accessoryViewWidth + 10.0 : 0.0) - (imageViewWidth > 0.0 ? imageViewWidth + 16.0 : 0.0)
        
        titleLabel.preferredMaxLayoutWidth = allowedTextWidth
        valueLabel.preferredMaxLayoutWidth = allowedTextWidth
    }
    
    private func updateLabelHiddenState(_ label: UILabel) {
        if label == titleLabel {
            titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
            return
        }
        
        let valueEmpty = valueLabel.text?.isEmpty ?? true
        valueLabel.isHidden = valueEmpty
        placeholderLabel.isHidden = placeholderLabel.text?.isEmpty ?? true || valueEmpty == false
    }
    
    private func updateValueHeightConstraint() {
        valueHeightConstraint.constant = valueLabel.font.lineHeight.ceiled(toScale: traitCollection.currentDisplayScale)
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
    ///   - singleLineValue:    A boolean value indicating if the value text should be constrained to a single line. The default is `false`.
    ///   - accessoryViewWidth: The width for the accessory view.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: String?, value: String?, compatibleWith traitCollection: UITraitCollection,
                                        image: UIImage? = nil, titleFont: UIFont? = nil, valueFont: UIFont? = nil,
                                        singleLineTitle: Bool = true, singleLineValue: Bool = false, accessoryViewWidth: CGFloat = 0.0) -> CGFloat {
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
        
        return max(titleWidth, valueWidth) + imageSpace + (accessoryViewWidth > 0.00001 ? accessoryViewWidth + 10.0 : 0.0)
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
    ///   - singleLineTitle: A boolean value indicating if the title text should be constrained to a single line. The default is `false`.
    ///   - singleLineValue: A boolean value indicating if the value text should be constrained to a single line. The default is `false`.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: String?, value: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         image: UIImage? = nil, titleFont: UIFont? = nil, valueFont: UIFont? = nil,
                                         singleLineTitle: Bool = true, singleLineValue: Bool = false) -> CGFloat {
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
        let combinedHeight = titleHeight + valueHeight + CellTitleSubtitleSeparation
        
        return max(combinedHeight, (imageSize?.height ?? 0.0))
    }
}
