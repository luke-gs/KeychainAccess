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
    public static var isInstalled: Bool = false {
        didSet {
            if isInstalled == oldValue {
                return
            }
            
            let notificationCenter = NotificationCenter.default
            
            if isInstalled {
                if KeyboardNumberBar.isSupported == false {
                    isInstalled = false
                    return
                }
                
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
                
                if let currentResponder = globalNumberBar.textInputView as? UIResponder {
                    removeNumberBar(from: currentResponder, reloadingInputViews: true)
                }
                cachedKeyboardTypes.removeAll()
            }
        }
    }
    
    
    /// Indicates whether the Keyboard Number Bar is supported on this device.
    ///
    /// Currently the bar is supported on all iPhones, and iPads without a number bar
    /// on its default keyboard.
    public static let isSupported: Bool = {
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
    
    fileprivate static var cachedKeyboardTypes: [UIResponder: UIKeyboardType] = [:]
    fileprivate static let globalNumberBar = KeyboardNumberBar()
    
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
    
    fileprivate lazy var lightButtonImage         = KeyboardNumberBar.newButtonImage(forDarkTheme: false, selected: false)
    fileprivate lazy var lightButtonSelectedImage = KeyboardNumberBar.newButtonImage(forDarkTheme: false, selected: true)
    fileprivate lazy var darkButtonImage          = KeyboardNumberBar.newButtonImage(forDarkTheme: true,  selected: false)
    
    
    // MARK: - Initializers
    
    private init() {
        func newButton(_ index: Int, text: String) -> UIButton {
            let button = UIButton(type: .custom)
            button.titleLabel?.font = .systemFont(ofSize: 20.0)
            button.setTitle(text, for: .normal)
            button.tag = index
            return button
        }
        
        keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        buttons = keys.enumerated().map(newButton)
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 50.0), inputViewStyle: .keyboard)
        
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
        
        let size = bounds.size
        let screenScale = UIScreen.main.scale
        
        let horizontalSpacing: CGFloat
        let edgeInset: CGFloat
        let verticalSpacing: CGFloat   = 6.0
        
        if traitCollection.horizontalSizeClass == .regular {
            if UIDevice.current.userInterfaceIdiom == .phone {
                edgeInset = 3.0
                horizontalSpacing = 5.0
            } else {
                if size.width >= 1000.0 {
                    edgeInset = 7.0
                    horizontalSpacing = 14.0
                } else {
                    edgeInset = 6.0
                    horizontalSpacing = 12.0
                }
            }
        } else {
            edgeInset = size.width > 400.0 ? 4.0 : 3.0
            horizontalSpacing = 6.0
        }
        
        let maximumSpacing: CGFloat = (horizontalSpacing * (buttonCount - 1)) + (edgeInset * 2.0)
        let buttonWidth: CGFloat    = (size.width - maximumSpacing) / buttonCount
        let buttonHeight: CGFloat   = size.height - (verticalSpacing * 2.0)
        
        var xPosition = edgeInset
        for button in buttons {
            button.frame = CGRect(x: (xPosition).floored(toScale: screenScale), y: verticalSpacing, width: buttonWidth.ceiled(toScale: screenScale), height: buttonHeight)
            xPosition = xPosition + buttonWidth + horizontalSpacing
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
        
        let endOfDocument = view.endOfDocument
        guard let selectedTextRange = view.selectedTextRange ?? view.textRange(from: endOfDocument, to: endOfDocument) else { return }
        
        let selectionStart = selectedTextRange.start
        let selectionEnd   = selectedTextRange.end
        
        let location = view.offset(from: view.beginningOfDocument, to: selectionStart)
        let length   = view.offset(from: selectionStart,           to: selectionEnd)
        let range    = NSRange(location: location, length: length)
        
        let newText = keys[button.tag]
        
        let shouldReplace: Bool
        if let textField = view as? UITextField {
            shouldReplace = textField.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: newText) ?? true
        } else if let textView = view as? UITextView {
            shouldReplace = textView.delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: newText) ?? true
        } else {
            shouldReplace = false
        }
        
        if shouldReplace {
            view.replace(selectedTextRange, withText: newText)
        }
    }
    
    fileprivate class func applyNumberBar(to responder: UIResponder, reloadingInputViews: Bool) {
        if isInstalled == false || responder.inputAccessoryView != nil { return }
        
        
        let useNumberBar: Bool
        if let textView = responder as? UITextView {
            let keyboardType = textView.keyboardType
            cachedKeyboardTypes[textView] = keyboardType
            
            switch keyboardType {
            case .numberPad, .decimalPad, .numbersAndPunctuation, .namePhonePad, .asciiCapableNumberPad:
                if UIDevice.current.userInterfaceIdiom != .phone {
                    textView.keyboardType = .default
                    useNumberBar = true
                } else {
                    useNumberBar = false
                }
            default:
                useNumberBar = true
            }
            
            if useNumberBar {
                textView.inputAccessoryView         = globalNumberBar
                globalNumberBar.textInputView      = textView
                globalNumberBar.keyboardAppearance = textView.keyboardAppearance
            }
        } else if let textField = responder as? UITextField {
            let keyboardType = textField.keyboardType
            cachedKeyboardTypes[textField] = keyboardType
            
            switch keyboardType {
            case .numberPad, .decimalPad, .numbersAndPunctuation, .namePhonePad, .asciiCapableNumberPad:
                if UIDevice.current.userInterfaceIdiom != .phone {
                    textField.keyboardType = .default
                    useNumberBar = true
                } else {
                    useNumberBar = false
                }
            default:
                useNumberBar = true
            }
            
            if useNumberBar {
                textField.inputAccessoryView         = globalNumberBar
                globalNumberBar.textInputView      = textField
                globalNumberBar.keyboardAppearance = textField.keyboardAppearance
            }
        }
        if reloadingInputViews {
            responder.reloadInputViews()
        }
    }
    
    fileprivate class func removeNumberBar(from responder: UIResponder, reloadingInputViews: Bool) {
        guard let cachedKeyboardType = cachedKeyboardTypes.removeValue(forKey: responder) else { return }
        
        if let textView = responder as? UITextView {
            if textView.inputAccessoryView == globalNumberBar {
                textView.inputAccessoryView = nil
            }
            textView.keyboardType = cachedKeyboardType
        } else if let textField = responder as? UITextField {
            if textField.inputAccessoryView == globalNumberBar {
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
        let image = light ? lightButtonImage : darkButtonImage
        let selectedImage: UIImage? = light ? lightButtonSelectedImage : nil
        
        for button in buttons {
            button.setTitleColor(titleColor,         for: .normal)
            button.setBackgroundImage(image,         for: .normal)
            button.setBackgroundImage(selectedImage, for: .highlighted)
        }
    }
    
    fileprivate class func newButtonImage(forDarkTheme dark: Bool, selected: Bool) -> UIImage {
        // We don't use a more generic method because we want to add shadow, and we want a specifical
        // shadow without any blur. 
        let imageRenderer = UIGraphicsImageRenderer(size: CGSize(width: 9.0, height: 10.0))
        let image = imageRenderer.image { (_: UIGraphicsImageRendererContext) in
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            context.addPath(CGPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: 9.0, height: 9.0), cornerWidth: 4.0, cornerHeight: 4.0, transform: nil))
            context.setShadow(offset: CGSize(width: 0.0, height: 1.0), blur: 0.0, color: #colorLiteral(red: 0.537254902, green: 0.5450510979, blue: 0.5607843137, alpha: 1).cgColor)
            
            let color: UIColor
            if dark {
                color = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 1)
            } else {
                color = selected ? #colorLiteral(red: 0.6823529412, green: 0.7019607843, blue: 0.7450980392, alpha: 1) : .white
            }
            color.setFill()
            context.fillPath()
        }
        
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 5.0, right: 4.0), resizingMode: .stretch)
    }
    
}
