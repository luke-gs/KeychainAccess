//
//  FormTextField.swift
//  VCom
//
//  Created by Rod Brown on 18/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

open class FormTextField: UITextField {
    
    fileprivate var _unitLabel: UILabel?
    open var unitLabel: UILabel {
        if _unitLabel == nil {
            _unitLabel = UILabel(frame: .zero)
            _unitLabel!.textColor = textColor
            _unitLabel!.font      = font
            _unitLabel!.isHidden    = true
            _unitLabel!.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: [], context: &kvoContext)
            addSubview(_unitLabel!)
        }
        return _unitLabel!
    }
    
    fileprivate var valueInset: CGFloat = 0.0 {
        didSet {
            if valueInset != oldValue {
                updateUnitLabelOrigin()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        _unitLabel?.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
    }
}


/// Overrides
extension FormTextField {
    
    open override var text: String? {
        didSet {
            fm_textDidChange()
        }
    }
    
    open override var font: UIFont? {
        willSet {
            if font != newValue && _unitLabel?.font == font {
                _unitLabel?.font = newValue
                fm_textDidChange()
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
        didSet {
            fm_textDidChange()
        }
    }
    
    open override var frame: CGRect {
        didSet {
            fm_textDidChange()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateUnitLabelOrigin()
    }
    
    open override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            fm_textDidChange()
            return true
        }
        return false
    }
    
    open override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            fm_textDidChange()
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
                fm_textDidChange()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

private extension FormTextField {
    
    func commonInit() {
        addTarget(self, action: #selector(fm_textDidChange), for: .editingChanged)
    }
    
    @objc func fm_textDidChange() {
        let hidden = _unitLabel?.text?.isEmpty ?? true || text?.isEmpty ?? true
        
        _unitLabel?.isHidden = hidden
        if !hidden {
            if isEditing {
                valueInset = ceil(min(caretRect(for: endOfDocument).maxX, editingRect(forBounds: bounds).maxX)) + 4.0
            } else {
                if let text = self.text , text.isEmpty == false {
                    
                    let textRect = (text as NSString).size(attributes: [NSFontAttributeName: self.font ?? .systemFont(ofSize: UIFont.systemFontSize)])
                    valueInset = ceil(min(textRect.width + 1.0, self.textRect(forBounds: bounds).maxX)) + 4.0
                } else {
                    valueInset =  4.0
                }
            }
        }
    }
    
    func updateUnitLabelOrigin() {
        _unitLabel?.frame.origin = CGPoint(x: valueInset, y: 1.0)
    }
    
}
