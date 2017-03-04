//
//  KeyboardNumberBar.swift
//  MPOL-UI
//
//  Created by Rod Brown on 7/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

public class KeyboardNumberBar: UIInputView {
    
    /// Updates whether the KeyboardNumberBar is globally installed on every text view and text field.
    /// The default is `false`.
    ///
    /// When set to `true`, the global KeyboardNumberBar will install itself on every `UITextView`,
    /// or `UITextField` instance when it becomes active, if it does not have its own custom
    /// textAccessoryView.
    public class var isInstalled: Bool {
        get {
            return _isInstalled
        }
        @objc(setInstalled:) set {
            if _isInstalled == newValue || (newValue && isNumberBarSupported == false) { return }
            
            _isInstalled = newValue
            
            let notificationCenter = NotificationCenter.default
            if newValue {
                let beginSelector = #selector(textControlDidBeginEditing(_:))
                let endSelector   = #selector(textControlDidEndEditing(_:))
                notificationCenter.addObserver(self, selector: beginSelector, name: NSNotification.Name(rawValue: "MPOL_UITextViewTextWillBeginEditingNotification"), object: nil)
                notificationCenter.addObserver(self, selector: beginSelector, name: .UITextFieldTextDidBeginEditing, object: nil)
                notificationCenter.addObserver(self, selector: endSelector,   name: .UITextViewTextDidEndEditing, object: nil)
                notificationCenter.addObserver(self, selector: endSelector,   name: .UITextFieldTextDidEndEditing, object: nil)
                
                if let currentResponder = UIApplication.shared.keyWindow?.firstResponderSubview(), currentResponder.inputAccessoryView == nil {
                    applyNumberBar(to: currentResponder, reloadingInputViews: true)
                }
            } else {
                notificationCenter.removeObserver(self)
                
                if let currentResponder = _globalNumberBar.textInputView as? UIResponder {
                    removeNumberBar(from: currentResponder, reloadingInputViews: true)
                }
                _cachedKeyboardTypes.removeAll()
            }
        }
    }
    
    public static let isNumberBarSupported: Bool = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return true
        case .pad:
            let size  = UIScreen.main.bounds.size
            
            // On iPads, only support devices that don't have the number bar in the default
            // keyboard. The best guess for this at this stage is the screen real-estate
            // to avoid hard coding against device models
            return max(size.width, size.height) < 1366.0
        default:
            return false
        }
    }()
    
    
    fileprivate static var _isInstalled: Bool = false
    fileprivate static var _cachedKeyboardTypes: [UIResponder: UIKeyboardType] = [:]
    fileprivate static let _globalNumberBar = KeyboardNumberBar()
    
    /// The text input view the number bar should forward text entry events towards.
    fileprivate weak var textInputView: UITextInput?
    
    fileprivate let keys: [String]
    fileprivate let buttons: [UIButton]
    
    fileprivate var keyboardAppearance: UIKeyboardAppearance = .light {
        didSet {
            if (oldValue == .dark) != (keyboardAppearance == .dark) {
                updateKeyboardAppearance()
            }
        }
    }
    
    fileprivate lazy var lightButtonImage         = UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: .white)
    fileprivate lazy var lightButtonSelectedImage = UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: #colorLiteral(red: 0.6823529412, green: 0.7019607843, blue: 0.7450980392, alpha: 1))
    fileprivate lazy var darkButtonImage          = UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 1))
    
    
    // MARK: - Initializers
    
    private init() {
        let mainScreen = UIScreen.main
        let buttonShadow: CGFloat = 1.0 / mainScreen.scale
        
        func newButton(_ index: Int, text: String) -> UIButton {
            let button = UIButton(type: .custom)
            button.titleLabel?.font = .systemFont(ofSize: 20.0)
            button.setTitle(text, for: .normal)
            button.tag = index
            
            let layer = button.layer
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 0.0
            layer.shadowOffset = CGSize(width: 0.0, height: buttonShadow)
            layer.shadowOpacity = 0.8
            
            return button
        }
        
        keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        buttons = keys.enumerated().map(newButton)
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: mainScreen.bounds.width, height: 50.0), inputViewStyle: .keyboard)
        
        for button in buttons {
            button.addTarget(self, action: #selector(touchDown(in:)), for: .touchDown)
            button.addTarget(self, action: #selector(touchUp(in:)),   for: .touchUpInside)
            addSubview(button)
        }
        
        updateKeyboardAppearance()
    }
    
    
    /// `KeyboardNumberBar` cannot be instantiated directly, and does not suport NSCoding.
    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("KeyboardNumberBar cannot be instantiated directly, and does not suport NSCoding.")
    }
    
}

extension KeyboardNumberBar: UIInputViewAudioFeedback {
    
    /**
     Enables keyboard clicks. This always returns `true` for `KeyboardNumberBar`.
     
     Subclasses can override and return `false`.
     */
    public var enableInputClicksWhenVisible: Bool { return true }
    
}

extension KeyboardNumberBar {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonCount: CGFloat = CGFloat(buttons.count)
        
        let horizontalSpacing: CGFloat = 14.0
        let verticalSpacing: CGFloat   = 6.0
        let radius: CGFloat            = 3.5
        
        let size = bounds.size
        
        let maximumSpacing: CGFloat = horizontalSpacing * buttonCount
        let buttonWidth: CGFloat    = (size.width - maximumSpacing) / buttonCount
        let buttonHeight: CGFloat   = size.height - (verticalSpacing * 2.0)
        
        let offset: CGFloat = 1.0 / UIScreen.main.scale
        
        let shadowPath = UIBezierPath(roundedRect: CGRect(x: offset, y: buttonHeight - (radius * 2.0), width: floor(buttonWidth) - (offset * 2.0), height: radius * 2.0), cornerRadius: radius).cgPath
        
        var xPosition = round(horizontalSpacing * 0.5)
        for button in buttons {
            button.frame = CGRect(x: xPosition, y: verticalSpacing, width: buttonWidth, height: buttonHeight)
            button.layer.shadowPath = shadowPath
            
            xPosition = round(xPosition + buttonWidth + horizontalSpacing)
        }
    }
    
}

fileprivate extension KeyboardNumberBar {
    
    @objc fileprivate class func textControlDidBeginEditing(_ notification: Notification) {
        if isInstalled, let responder = notification.object as? UIResponder {
            applyNumberBar(to: responder, reloadingInputViews: false)
        }
    }
    
    @objc fileprivate class func textControlDidEndEditing(_ notification: Notification) {
        if let responder = notification.object as? UIResponder {
            removeNumberBar(from: responder, reloadingInputViews: false)
        }
    }
    
    @objc fileprivate func touchDown(in button: UIButton) {
        UIDevice.current.playInputClick()
    }
    
    @objc fileprivate func touchUp(in button: UIButton) {
        guard let view = textInputView else { return }
        
        let beginning         = view.beginningOfDocument
        let selectedTextRange = view.selectedTextRange ?? view.textRange(from: beginning, to: beginning)!
        let selectionStart    = selectedTextRange.start
        let selectionEnd      = selectedTextRange.end
        let location          = view.offset(from: beginning,      to: selectionStart)
        let length            = view.offset(from: selectionStart, to: selectionEnd)
        
        let newText = keys[button.tag]
        
        let shouldReplace: Bool
        if let textField = view as? UITextField {
            shouldReplace = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSRange(location: location, length: length), replacementString: newText) ?? true
        } else if let textView = view as? UITextView {
            shouldReplace = textView.delegate?.textView?(textView, shouldChangeTextIn: NSRange(location: location, length: length), replacementText: newText) ?? true
        } else {
            shouldReplace = true
        }
        
        if shouldReplace {
            view.replace(selectedTextRange, withText: newText)
        }
    }
    
    fileprivate class func applyNumberBar(to responder: UIResponder, reloadingInputViews: Bool) {
        if _isInstalled == false || responder.inputAccessoryView != nil { return }
        
        
        let useNumberBar: Bool
        if let textView = responder as? UITextView {
            let keyboardType = textView.keyboardType
            _cachedKeyboardTypes[textView] = keyboardType
            
            switch keyboardType {
            case .numberPad, .decimalPad, .numbersAndPunctuation, .namePhonePad:
                textView.keyboardType = .default
                useNumberBar = UIDevice.current.userInterfaceIdiom != .phone
            default:
                useNumberBar = true
            }
            
            if useNumberBar {
                textView.inputAccessoryView         = _globalNumberBar
                _globalNumberBar.textInputView      = textView
                _globalNumberBar.keyboardAppearance = textView.keyboardAppearance
            }
        } else if let textField = responder as? UITextField {
            let keyboardType = textField.keyboardType
            _cachedKeyboardTypes[textField] = keyboardType
            
            switch keyboardType {
            case .numberPad, .decimalPad, .numbersAndPunctuation, .namePhonePad:
                textField.keyboardType = .default
                useNumberBar = UIDevice.current.userInterfaceIdiom != .phone
            default:
                useNumberBar = true
            }
            
            if useNumberBar {
                textView.inputAccessoryView         = _globalNumberBar
                _globalNumberBar.textInputView      = textView
                _globalNumberBar.keyboardAppearance = textView.keyboardAppearance
            }
        }
        if reloadingInputViews {
            responder.reloadInputViews()
        }
    }
    
    fileprivate class func removeNumberBar(from responder: UIResponder, reloadingInputViews: Bool) {
        guard let cachedKeyboardType = _cachedKeyboardTypes.removeValue(forKey: responder) else { return }
        
        if let textView = responder as? UITextView {
            if textView.inputAccessoryView == _globalNumberBar {
                textView.inputAccessoryView = nil
            }
            textView.keyboardType = cachedKeyboardType
        } else if let textField = responder as? UITextField {
            if textField.inputAccessoryView == _globalNumberBar {
                textField.inputAccessoryView = nil
            }
            textField.keyboardType = cachedKeyboardType
        }
        
        if reloadingInputViews {
            responder.reloadInputViews()
        }
    }
    
    fileprivate func updateKeyboardAppearance() {
        let light = keyboardAppearance != .dark
        let titleColor: UIColor = light ? .black : .white
        let backgroundImage     = light ? lightButtonImage : darkButtonImage
        let selectedBackgroundImage: UIImage? = light ? lightButtonSelectedImage : nil
        
        for button in buttons {
            button.setTitleColor(titleColor, for: .normal)
            button.setBackgroundImage(backgroundImage, for: .normal)
            button.setBackgroundImage(selectedBackgroundImage, for: .highlighted)
        }
    }
    
}
