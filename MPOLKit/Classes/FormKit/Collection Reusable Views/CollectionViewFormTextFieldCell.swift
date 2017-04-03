//
//  CollectionViewFormTextFieldCell.swift
//  MPOLKit/FormKit
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
    
    
    // MARK: - Private properties
    
    private var titleDetailSeparationConstraint: NSLayoutConstraint!
    
    
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
        
        let contentView            = self.contentView
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints  = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        titleDetailSeparationConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: textField, attribute: .leading,  relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textField, attribute: .bottom,   relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .bottom, constant: 0.5),
            titleDetailSeparationConstraint
        ])
        
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: .UITextFieldTextDidBeginEditing, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing(_:)),   name: .UITextFieldTextDidEndEditing,   object: textField)
    }
    
    deinit {
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override var bounds: CGRect {
        didSet {
            let width = bounds.width
            if width !=~ oldValue.width {
                titleLabel.preferredMaxLayoutWidth    = width
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            let width = frame.width
            if width !=~ oldValue.width {
                titleLabel.preferredMaxLayoutWidth    = width
            }
        }
    }
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        if #available(iOS 10, *) {
            let traitCollection       = self.traitCollection
            titleLabel.font           = .preferredFont(forTextStyle: .footnote,    compatibleWith: traitCollection)
            textField.font            = .preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection)
            textField.placeholderFont = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            titleLabel.font           = .preferredFont(forTextStyle: .footnote)
            textField.font            = .preferredFont(forTextStyle: .headline)
            textField.placeholderFont = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            
            let titleDetailSpace = titleLabel.text?.isEmpty ?? true ? 0.0 : CellTitleSubtitleSeparation
            
            if titleDetailSeparationConstraint.constant !=~ titleDetailSpace {
                titleDetailSeparationConstraint.constant = titleDetailSpace
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Accessibility
    
    open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return titleLabel.text
        }
        set {
            super.accessibilityLabel = newValue
        }
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
        let titleTextFont:       UIFont
        let enteredTextFont:     UIFont
        let placeholderTextFont: UIFont
        
        if #available(iOS 10, *) {
            titleTextFont       = titleFont       ?? .preferredFont(forTextStyle: .footnote,    compatibleWith: traitCollection)
            enteredTextFont     = textFieldFont   ?? .preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection)
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            titleTextFont       = titleFont       ?? .preferredFont(forTextStyle: .footnote)
            enteredTextFont     = textFieldFont   ?? .preferredFont(forTextStyle: .headline)
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline)
        }
        
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
            let titleTextFont: UIFont
            if #available(iOS 10, *) {
                titleTextFont = titleFont ?? .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            } else {
                titleTextFont = titleFont ?? .preferredFont(forTextStyle: .footnote)
            }
            titleHeight = singleLineTitle ? titleTextFont.lineHeight.ceiled(toScale: displayScale) : (title as NSString?)?.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), attributes: [NSFontAttributeName: titleTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0
            titleHeight += CellTitleSubtitleSeparation
        }
        
        let enteredTextFont: UIFont
        let placeholderTextFont: UIFont
        if #available(iOS 10, *) {
            enteredTextFont     = textFieldFont   ?? .preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection)
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            enteredTextFont     = textFieldFont   ?? .preferredFont(forTextStyle: .headline)
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline)
        }
        
        return titleHeight + max(enteredTextFont.lineHeight, placeholderTextFont.lineHeight).ceiled(toScale: displayScale)
    }
    
}
