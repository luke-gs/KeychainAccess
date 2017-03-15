//
//  FormTextField.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 18/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

open class FormTextField: UITextField {
    
    public var unitLabel: UILabel {
        if let unitLabel = _unitLabel { return unitLabel }
        
        let unitLabel = UILabel(frame: .zero)
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.textColor = textColor
        unitLabel.font      = font
        unitLabel.isHidden  = true
        unitLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text),  context: &kvoContext)
        addSubview(unitLabel)
        
        unitLabelOriginXConstraint = NSLayoutConstraint(item: unitLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, constant: valueInset)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: unitLabel, attribute: .firstBaseline, relatedBy: .equal, toItem: self, attribute: .firstBaseline),
            unitLabelOriginXConstraint!
        ])
        
        _unitLabel = unitLabel
        return unitLabel
    }
    
    @NSCopying public var placeholderFont: UIFont? {
        didSet { if placeholderFont != oldValue { updatePlaceholder() } }
    }
    
    @NSCopying public var placeholderTextColor: UIColor? {
        didSet { if placeholderTextColor != oldValue { updatePlaceholder() } }
    }
    
    fileprivate var placeholderText: String? {
        didSet { if placeholderText != oldValue { updatePlaceholder() }}
    }
    
    fileprivate var _unitLabel: UILabel?
    
    fileprivate var valueInset: CGFloat = 0.0 {
        didSet { if valueInset != oldValue { unitLabelOriginXConstraint?.constant = valueInset } }
    }
    
    fileprivate var unitLabelOriginXConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    deinit {
        _unitLabel?.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
    }
}


/// Overrides
extension FormTextField {
    
    open override var text: String? {
        didSet { textDidChange() }
    }
    
    open override var font: UIFont? {
        willSet {
            if newValue != _unitLabel?.font {
                _unitLabel?.font = newValue
                textDidChange()
                setNeedsLayout()
            }
        }
    }
    
    open override var textColor: UIColor? {
        didSet {
            if textColor != oldValue {
                if _unitLabel?.textColor == oldValue {
                    _unitLabel?.textColor = textColor
                }
            }
        }
    }
    
    open override var placeholder: String? {
        get { return placeholderText }
        set { placeholderText = newValue }
    }
    
    open override var attributedPlaceholder: NSAttributedString? {
        get { return super.attributedPlaceholder }
        set { self.placeholderText = newValue?.string }
    }
    
    open override var bounds: CGRect {
        didSet { textDidChange() }
    }
    
    open override var frame: CGRect {
        didSet { textDidChange() }
    }
    
    open override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            textDidChange()
            return true
        }
        return false
    }
    
    open override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            textDidChange()
            return true
        }
        return false
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        
        let inset = _unitLabel?.frame.width ?? 0.0 + ((clearButtonMode == .whileEditing || clearButtonMode == .whileEditing) ? 25.0 : 4.0)
        let adjustment = min(textRect.width, inset)
        
        textRect.size.width -= adjustment
        if traitCollection.layoutDirection == .rightToLeft {
            textRect.origin.x += adjustment
        }
        
        return textRect
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editingRect = super.editingRect(forBounds: bounds)
        
        let inset = _unitLabel?.frame.width ?? 0.0 + ((clearButtonMode == .whileEditing || clearButtonMode == .whileEditing) ? 25.0 : 4.0)
        let adjustment = min(editingRect.width, inset)
        
        editingRect.size.width -= adjustment
        if traitCollection.layoutDirection == .rightToLeft {
            editingRect.origin.x += adjustment
        }
        
        return editingRect
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if _unitLabel?.text?.isEmpty ?? true == false {
                _unitLabel!.sizeToFit()
                textDidChange()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if adjustsFontForContentSizeCategory,
            traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory,
            let placeholderFontType = placeholderFont?.fontDescriptor.fontAttributes["NSCTFontUIUsageAttribute"] as? String {
            placeholderFont = .preferredFont(forTextStyle: UIFontTextStyle(rawValue: placeholderFontType), compatibleWith: traitCollection)
        }
    }
    
}



fileprivate extension FormTextField {
    
    @objc fileprivate func textDidChange() {
        let hidden = _unitLabel?.text?.isEmpty ?? true || text?.isEmpty ?? true
        
        _unitLabel?.isHidden = hidden
        
        if !hidden {
            
            if traitCollection.layoutDirection == .rightToLeft {
                
                if isEditing, let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                    // Get the maximum text rectangle for the text
                    let maxTextRect = self.textRect(forBounds: bounds)
                    
                    // get the text rectangle and fix for the fact it's offset by the maxTextRect origin.
                    var textRect = firstRect(for: textRange)
                    textRect.origin.x += maxTextRect.origin.x
                    
                    // work out the intersection - only the text rect where its in the text max bounds
                    textRect = textRect.intersection(maxTextRect)
                    textRect = textRect.integral
                    
                    valueInset = bounds.width - textRect.minX + 2.0
                } else if let text = self.text, text.isEmpty == false {
                    let textWidth = text.boundingRect(with: .max, attributes:  [NSFontAttributeName: self.font ?? .systemFont(ofSize: UIFont.systemFontSize)] , context: nil).width
                    let maxTextRect = textRect(forBounds: bounds)
                    valueInset = bounds.width - maxTextRect.maxX + ceil(min(textWidth, maxTextRect.width)) + 2.0
                } else {
                    valueInset = 2.0
                }
            } else {
                if isEditing, let textRange = self.textRange(from: beginningOfDocument, to: endOfDocument) {
                    // Get the maximum text rectangle for the text
                    let maxTextRect = self.textRect(forBounds: bounds)
                    
                    // get the text rectangle and fix for the fact it's offset by the maxTextRect origin.
                    var textRect = firstRect(for: textRange)
                    textRect.origin.x += maxTextRect.origin.x
                    
                    // work out the intersection - only the text rect where its in the text max bounds
                    textRect = textRect.intersection(maxTextRect)
                    textRect = textRect.integral
                    
                    valueInset = textRect.maxX + 2.0
                } else if let text = self.text, text.isEmpty == false {
                    let textWidth = text.boundingRect(with: .max, attributes:  [NSFontAttributeName: self.font ?? .systemFont(ofSize: UIFont.systemFontSize)] , context: nil).width
                    let maxTextRect = textRect(forBounds: bounds)
                    valueInset = maxTextRect.minX + ceil(min(textWidth, maxTextRect.width)) + 2.0
                } else {
                    valueInset = 2.0
                }
            }
        }
    }
    
    fileprivate func updatePlaceholder() {
        if let placeholder = placeholderText, placeholder.isEmpty == false {
            let attributes = [NSFontAttributeName: self.placeholderFont ?? UIFont.systemFont(ofSize: 15.0), NSForegroundColorAttributeName: self.placeholderTextColor ?? .lightGray]
            super.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        } else {
            super.attributedPlaceholder = nil
        }
    }
    
}
