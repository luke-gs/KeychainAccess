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
        unitLabel.textColor = textColor
        unitLabel.font      = font
        unitLabel.isHidden  = true
        unitLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text),  context: &kvoContext)
        addSubview(unitLabel)
        _unitLabel = unitLabel
        return unitLabel
    }
    
    @NSCopying public var placeholderFont: UIFont? {
        didSet { if placeholderFont != oldValue { updatePlaceholder() } }
    }
    
    @NSCopying public var placeholderTextColor: UIColor? {
        didSet { if placeholderTextColor != oldValue { updatePlaceholder() } }
    }
    
    fileprivate var _unitLabel: UILabel?
    
    fileprivate var valueInset: CGFloat = 0.0 {
        didSet { if valueInset != oldValue { updateUnitLabelOrigin() } }
    }
    
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
            if font != newValue && _unitLabel?.font == font {
                _unitLabel?.font = newValue
                textDidChange()
                setNeedsLayout()
            }
        }
    }
    
    open override var textColor: UIColor? {
        didSet {
            if oldValue == unitLabel.textColor {
                _unitLabel?.textColor = textColor
            }
        }
    }
    
    open override var bounds: CGRect {
        didSet { textDidChange() }
    }
    
    open override var frame: CGRect {
        didSet { textDidChange() }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateUnitLabelOrigin()
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
        textRect.size.width -= _unitLabel?.frame.width ?? 0.0 + (clearButtonMode == .whileEditing ? 25.0 : 4.0)
        return textRect
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editingRect = super.editingRect(forBounds: bounds)
        editingRect.size.width -= _unitLabel?.frame.width ?? 0.0 + 4.0
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
            if isEditing {
                valueInset = ceil(min(caretRect(for: endOfDocument).maxX, editingRect(forBounds: bounds).maxX)) + 4.0
            } else if let text = self.text , text.isEmpty == false {
                
                let textRect = text.boundingRect(with: .max, attributes:  [NSFontAttributeName: self.font ?? .systemFont(ofSize: UIFont.systemFontSize)] , context: nil)
                valueInset = ceil(min(textRect.width + 1.0, self.textRect(forBounds: bounds).maxX)) + 4.0
            } else {
                valueInset =  4.0
            }
        }
    }
    
    fileprivate func updatePlaceholder() {
        let attributes = [NSFontAttributeName: self.placeholderFont ?? UIFont.systemFont(ofSize: 15.0), NSForegroundColorAttributeName: self.placeholderTextColor ?? .lightGray]
        
        if let attributedPlaceholder = self.attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString {
            attributedPlaceholder.setAttributes(attributes, range: NSRange(location: 0, length: attributedPlaceholder.length))
            self.attributedPlaceholder = attributedPlaceholder
        } else if let placeholder = self.placeholder, placeholder.isEmpty == false {
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        } else {
            self.attributedPlaceholder = nil
        }
    }
    
    fileprivate func updateUnitLabelOrigin() {
        _unitLabel?.frame.origin = CGPoint(x: valueInset, y: 1.0)
    }
    
}
