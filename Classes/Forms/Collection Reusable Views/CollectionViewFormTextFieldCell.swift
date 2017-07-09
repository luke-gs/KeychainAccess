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
    
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet { if isSelected && oldValue == false && textField.isEnabled { _ = textField.becomeFirstResponder() } }
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
        selectionStyle = .underline
        
        textField.clearButtonMode = .whileEditing
        
        titleLabel.adjustsFontForContentSizeCategory = true
        textField.adjustsFontForContentSizeCategory = true
        
        titleLabel.font           = .preferredFont(forTextStyle: .footnote)
        textField.font            = .preferredFont(forTextStyle: .headline)
        textField.placeholderFont = .preferredFont(forTextStyle: .subheadline)
        
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
        
        // Get content sizes
        
        let interItemSpace = CellTitleSubtitleSeparation.ceiled(toScale: displayScale)
        
        let labelSize = titleLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        var textFieldSize = CGSize(width: contentRect.width, height: textField.intrinsicContentSize.height)
        if textFieldSize.height == UIViewNoIntrinsicMetric {
            textFieldSize.height = textField.font?.lineHeight ?? 18.0 + 8.0
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
        
        accessoryView?.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.minX : contentRect.maxX - accessorySize.width, y: (contentYOrigin + (contentHeight - accessorySize.height) / 2.0).rounded(toScale: displayScale)), size: accessorySize)
        
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
    
    public class func minimumContentWidth(withTitle title: String?, enteredText: String?, placeholder: String?, compatibleWith traitCollection: UITraitCollection, titleFont: UIFont? = nil, textFieldFont: UIFont? = nil, placeholderFont: UIFont? = nil, singleLineTitle: Bool = true, accessoryViewWidth: CGFloat = 0.0) -> CGFloat {
        let titleTextFont:       UIFont = titleFont       ?? .preferredFont(forTextStyle: .footnote)
        let enteredTextFont:     UIFont = textFieldFont   ?? .preferredFont(forTextStyle: .headline)
        let placeholderTextFont: UIFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline)
        
        let displayScale = traitCollection.currentDisplayScale
        
        // title width can be shortcutted if we're doing multiple lines - we could break the text anywhere. Give decent minimal room.
        let titleWidth = singleLineTitle ? (title as NSString?)?.boundingRect(with: .max, attributes: [NSFontAttributeName: titleTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0 : 20.0
        
        // Allow additional text rectangle for the clear icon.
        let textWidth  = ((enteredText as NSString?)?.boundingRect(with: .max, attributes: [NSFontAttributeName: enteredTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0) + 10.0
        let placeWidth = ((placeholder as NSString?)?.boundingRect(with: .max, attributes: [NSFontAttributeName: placeholderTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0) + 10.0
        
        return max(titleWidth, textWidth, placeWidth) + (accessoryViewWidth > 0.00001 ? accessoryViewWidth + 10.0 : 0.0)
    }
    
    public class func minimumContentHeight(withTitle title: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection, titleFont: UIFont? = nil, textFieldFont: UIFont? = nil, placeholderFont: UIFont? = nil, singleLineTitle: Bool = true) -> CGFloat {
        
        let displayScale = traitCollection.currentDisplayScale
        
        var titleHeight: CGFloat
        if title?.isEmpty ?? true {
            titleHeight = 0.0
        } else {
            let titleTextFont: UIFont = titleFont ?? .preferredFont(forTextStyle: .footnote)
            titleHeight = singleLineTitle ? titleTextFont.lineHeight.ceiled(toScale: displayScale) : (title as NSString?)?.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), attributes: [NSFontAttributeName: titleTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0
            titleHeight += CellTitleSubtitleSeparation
        }
        
        let enteredTextFont:     UIFont = textFieldFont   ?? .preferredFont(forTextStyle: .headline)
        let placeholderTextFont: UIFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline)        
        return titleHeight + max(enteredTextFont.lineHeight, placeholderTextFont.lineHeight).ceiled(toScale: displayScale)
    }
    
}
