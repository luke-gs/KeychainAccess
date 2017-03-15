//
//  CollectionViewFormTextFieldCell.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

open class CollectionViewFormTextFieldCell: CollectionViewFormCell {
    
    
    /// The title label for the cell. This sits directly above the text field.
    open let titleLabel = UILabel(frame: .zero)
    
    
    /// The text field for the cell.
    open let textField = FormTextField(frame: .zero)
    
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet { if isSelected && oldValue == false { _ = textField.becomeFirstResponder() } }
    }
    
    
    // MARK: - Private properties
    
    fileprivate var titleDetailSeparationConstraint: NSLayoutConstraint!
    
    
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
    }
    
    deinit {
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            
            let titleDetailSpace = titleLabel.text?.isEmpty ?? true ? 0.0 : CellTitleDetailSeparation
            
            if titleDetailSeparationConstraint.constant !=~ titleDetailSpace {
                titleDetailSeparationConstraint.constant = titleDetailSpace
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}


extension CollectionViewFormTextFieldCell {
    
    public class func minimumContentWidth(withTitle title: String?, enteredText: String?, placeholder: String?, compatibleWith traitCollection: UITraitCollection, titleFont: UIFont? = nil, textFieldFont: UIFont? = nil, placeholderFont: UIFont? = nil, singleLineTitle: Bool = true) -> CGFloat {
        let titleTextFont   = titleFont       ?? CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
        let enteredTextFont = textFieldFont   ?? CollectionViewFormDetailCell.font(withEmphasis: true,  compatibleWith: traitCollection)
        
        let placeholderTextFont: UIFont
        if #available(iOS 10, *) {
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline)
        }
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        
        // title width can be shortcutted if we're doing multiple lines - we could break the text anywhere. Give decent minimal room.
        let titleWidth = singleLineTitle ? (title as NSString?)?.boundingRect(with: .max, attributes: [NSFontAttributeName: titleTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0 : 20.0
        
        // Allow additional text rectangle for the clear icon.
        let textWidth  = ((enteredText as NSString?)?.boundingRect(with: .max, attributes: [NSFontAttributeName: enteredTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0) + 10.0
        let placeWidth = ((placeholder as NSString?)?.boundingRect(with: .max, attributes: [NSFontAttributeName: placeholderTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0) + 10.0
        
        return max(titleWidth, textWidth, placeWidth)
    }
    
    public class func minimumContentHeight(withTitle title: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection, titleFont: UIFont? = nil, textFieldFont: UIFont? = nil, placeholderFont: UIFont? = nil, singleLineTitle: Bool = true) -> CGFloat {
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        var titleHeight: CGFloat
        if title?.isEmpty ?? true {
            titleHeight = 0.0
        } else {
            let titleTextFont = titleFont ?? CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
            titleHeight = singleLineTitle ? titleTextFont.lineHeight.ceiled(toScale: displayScale) : (title as NSString?)?.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), attributes: [NSFontAttributeName: titleTextFont], context: nil).width.ceiled(toScale: displayScale) ?? 0.0
            titleHeight += CellTitleDetailSeparation
        }
        
        let enteredTextFont = textFieldFont   ?? CollectionViewFormDetailCell.font(withEmphasis: true, compatibleWith: traitCollection)
        
        let placeholderTextFont: UIFont
        if #available(iOS 10, *) {
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            placeholderTextFont = placeholderFont ?? .preferredFont(forTextStyle: .subheadline)
        }
        
        return titleHeight + max(enteredTextFont.lineHeight, placeholderTextFont.lineHeight).ceiled(toScale: displayScale)
    }
    
}


extension CollectionViewFormTextFieldCell {
    
    internal override func applyStandardFonts() {
        titleLabel.font = CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
        textField.font  = CollectionViewFormDetailCell.font(withEmphasis: true,  compatibleWith: traitCollection)
        
        if #available(iOS 10, *) {
            textField.placeholderFont = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            textField.placeholderFont = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
}


// MARK: - Accessibility
/// Accessibility
extension CollectionViewFormTextFieldCell {
    
    dynamic open override var accessibilityLabel: String? {
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
    
    dynamic open override var accessibilityValue: String? {
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
    
    dynamic open override var isAccessibilityElement: Bool {
        get {
            if textField.isEditing { return false }
            return super.isAccessibilityElement
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }
    
}
