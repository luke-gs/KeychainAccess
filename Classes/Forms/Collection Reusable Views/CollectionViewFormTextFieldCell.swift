//
//  CollectionViewFormTextFieldCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

open class CollectionViewFormTextFieldCell: CollectionViewFormCell {
    
    // MARK: Public properties
    
    /// The title label for the cell. This sits directly above the text field.
    open let titleLabel = UILabel(frame: .zero)
    
    
    /// The text field for the cell.
    open let textField = FormTextField(frame: .zero)
    
    
    /// The vertical separation between the label and the text field.
    ///
    /// The default is the default MPOL Title-Subtitle separation.
    open var labelSeparation: CGFloat = CellTitleSubtitleSeparation {
        didSet {
            if labelSeparation !=~ oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet {
            if isSelected && oldValue == false && textField.isEnabled {
                _ = textField.becomeFirstResponder()
            } else if !isSelected && oldValue == true && textField.isFirstResponder {
                _ = textField.resignFirstResponder()
            }
        }
    }
    
    
    // MARK: - Initializers
    
    override func commonInit() {
        super.commonInit()
        
        selectionStyle = .underline
        
        textField.clearButtonMode = .whileEditing
        
        titleLabel.adjustsFontForContentSizeCategory = true
        textField.adjustsFontForContentSizeCategory = true
        
        titleLabel.font           = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        textField.font            = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        textField.placeholderFont = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        
        let contentView = self.contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
        }
        
        textField.addObserver(self, forKeyPath: #keyPath(UITextField.font), context: &kvoContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: .UITextFieldTextDidBeginEditing, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing(_:)),   name: .UITextFieldTextDidEndEditing,   object: textField)
    }
    
    deinit {
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
        }
        textField.removeObserver(self, forKeyPath: #keyPath(UITextField.font), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentView = self.contentView
        let displayScale = traitCollection.currentDisplayScale
        let isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        var contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        let contentTrailingEdge = isRightToLeft ? contentRect.minX : contentRect.maxX
        
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
        
        // Get content sizes
        
        
        let labelSize = titleLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        
        let interItemSpace = labelSize.isEmpty ? 0.0 : labelSeparation.ceiled(toScale: displayScale)
        
        var textFieldSize = CGSize(width: contentRect.width, height: textField.intrinsicContentSize.height)
        if textFieldSize.height == UIViewNoIntrinsicMetric {
            textFieldSize.height = textField.font?.lineHeight.ceiled(toScale: displayScale) ?? 18.0 + 8.0
        }
        
        let contentHeight = max(labelSize.height + textFieldSize.height + interItemSpace, accessorySize.height)
        
        // Get content positions
        
        let contentYOrigin: CGFloat
        switch contentMode {
        case .top, .topLeft, .topRight:
            contentYOrigin = contentRect.minY
        case .bottom, .bottomLeft, .bottomRight:
            contentYOrigin = max(contentRect.minY, contentRect.maxY - contentHeight)
        default:
            contentYOrigin = max(contentRect.minY, contentRect.midY - contentHeight / 2.0)
        }
        
        // Update frames
        
        accessoryView?.frame = CGRect(origin: CGPoint(x: contentTrailingEdge - (isRightToLeft ? 0.0 : accessorySize.width),
                                                      y: (contentYOrigin + ((contentHeight - accessorySize.height) / 2.0)).rounded(toScale: displayScale)),
                                      size: accessorySize)
        
        let titleFrame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - labelSize.width : contentRect.minX, y: contentYOrigin), size: labelSize)
        titleLabel.frame = titleFrame
        textField.frame = CGRect(origin: CGPoint(x: contentRect.minX, y: titleFrame.maxY + interItemSpace), size: textFieldSize)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Accessibility
    
    open override var accessibilityLabel: String? {
        get { return super.accessibilityLabel?.ifNotEmpty() ?? titleLabel.text }
        set { super.accessibilityLabel = newValue }
    }
    
    open override var accessibilityValue: String? {
        get {
            if let setValue = super.accessibilityValue {
                return setValue
            }
            let text = textField.text
            if text?.isEmpty ?? true {
                return textField.placeholder
            }
            return text
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
    open override var isAccessibilityElement: Bool {
        get {
            if textField.isEditing { return false }
            return super.isAccessibilityElement
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }
    
    
    // MARK: - Notifications
    
    @objc private func textFieldDidBeginEditing(_ notification: NSNotification) {
        guard isSelected == false,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    @objc private func textFieldDidEndEditing(_ notification: NSNotification) {
        guard isSelected,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content width for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - title:             The title details for sizing.
    ///   - enteredText:       The entered text value details for sizing.
    ///   - placeholder:       The placeholder text details for sizing.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: StringSizable?, enteredText: StringSizable?, placeholder: StringSizable?,
                                        compatibleWith traitCollection: UITraitCollection, accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing() ?? StringSizing(string: "")
        if titleSizing.font == nil {
            titleSizing.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        }
        if titleSizing.numberOfLines == nil {
            titleSizing.numberOfLines = 1
        }
        
        var enteredTextSizing = enteredText?.sizing() ?? StringSizing(string: "")
        enteredTextSizing.numberOfLines = 1
        if enteredTextSizing.font == nil {
            enteredTextSizing.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        }
        
        var placeholderSizing = enteredText?.sizing() ?? StringSizing(string: "")
        placeholderSizing.numberOfLines = 1
        if placeholderSizing.font == nil {
            placeholderSizing.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        }
        
        let titleWidth = titleSizing.minimumWidth(compatibleWith: traitCollection)
        let textWidth = enteredTextSizing.minimumWidth(compatibleWith: traitCollection)
        let placeWidth = placeholderSizing.minimumWidth(compatibleWith: traitCollection)
        
        let accessorySpace = accessoryViewSize.isEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset
        
        return max(titleWidth, textWidth, placeWidth) + accessorySpace
    }
    
    
    /// Calculates the minimum content height for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - title:             The title details for sizing.
    ///   - value:             The value details for sizing.
    ///   - width:             The content width for the cell.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - labelSeparation:   The separation between the label and the text field. The default is the standard separation.
    ///   - imageSize:         The size for the image, to present, or `.zero`. The default is `.zero`.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: StringSizable?, enteredText: StringSizable?, placeholder: StringSizable? = nil,
                                         inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         labelSeparation: CGFloat = CellTitleSubtitleSeparation, accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }
        
        var enteredTextSizing = enteredText?.sizing() ?? StringSizing(string: "")
        enteredTextSizing.numberOfLines = 1
        if enteredTextSizing.font == nil {
            enteredTextSizing.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        }
        
        var placeholderSizing = enteredText?.sizing() ?? StringSizing(string: "")
        placeholderSizing.numberOfLines = 1
        if placeholderSizing.font == nil {
            placeholderSizing.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        }
        
        let isAccesssoryEmpty = accessoryViewSize.isEmpty
        
        let availableWidth = width - (isAccesssoryEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset)
        
        let titleHeight = titleSizing?.minimumHeight(inWidth: availableWidth, compatibleWith: traitCollection) ?? 0.0
        let textHeight = enteredTextSizing.minimumHeight(inWidth: availableWidth, allowingZeroHeight: false, compatibleWith: traitCollection)
        let placeholderHeight = placeholderSizing.minimumHeight(inWidth: availableWidth, allowingZeroHeight: false, compatibleWith: traitCollection)
        let separator = titleHeight >~ 0.0 ? labelSeparation.ceiled(toScale: traitCollection.currentDisplayScale) : 0.0
        
        return max(titleHeight + max(textHeight, placeholderHeight) + separator, accessoryViewSize.height)
    }
    
}
