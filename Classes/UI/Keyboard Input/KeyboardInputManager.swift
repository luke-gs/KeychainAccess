//
//  KeyboardInputManager.swift
//  MPOLKit
//
//  Created by Rod Brown on 11/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreFoundation

fileprivate var keyboardAppearanceContext = 1

fileprivate var isNumberBarEnabledContext = 1
fileprivate let isNumberBarEnabledKey = "isNumberBarEnabled"

/// A keyboard manager that monitors the current active text field, and applies
/// adjustments globally each text field as it becomes active.
public class KeyboardInputManager: NSObject {

    // MARK: - Singleton
    
    /// The shared keyboard manager singleton.
    public static let shared: KeyboardInputManager = KeyboardInputManager()
    
    
    // MARK: - Public properties
    
    /// Indicates whether the Keyboard Number Bar is supported on this device.
    ///
    /// Currently the bar is supported on all iPhones, and iPads without a number bar
    /// on its default keyboard.
    public let isNumberBarSupported: Bool =  {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return true
        case .pad:
            let size  = UIScreen.main.bounds.size
            
            // On iPads, only support devices that don't have the number bar in the default
            // keyboard. The best  guess for this at this stage (at least in public API)
            // is the screen real-estate to avoid hard coding against device models.
            return max(size.width, size.height) < 1366.0
        default:
            return false
        }
    }()
    
    
    /// Updates whether the KeyboardNumberBar is globally installed on every text view and text field.
    ///
    /// When set to `true`, a global KeyboardNumberBar will be installed on every `UITextView`,
    /// or `UITextField` instance when it becomes active, if it does not have its own custom
    /// `textAccessoryView`.
    public var isNumberBarEnabled: Bool = UserDefaults.mpol.bool(forKey: isNumberBarEnabledKey) {
        didSet {
            if isNumberBarEnabled == oldValue {
                return
            }
            
            let userDefaults = UserDefaults.mpol
            if userDefaults.bool(forKey: isNumberBarEnabledKey) != isNumberBarEnabled {
                userDefaults.set(isNumberBarEnabled, forKey: isNumberBarEnabledKey)
            }
            
            if isNumberBarEnabled {
                if isNumberBarSupported == false {
                    isNumberBarEnabled = false
                    return
                }
                
                if let activeControl = activeTextControl, activeControl.inputAccessoryView == nil {
                    applyNumberBar(to: activeControl, reloadingInputViews: true)
                }
            } else {
                if let currentView = numberBar?.textInputView as? UIView {
                    removeNumberBar(from: currentView, reloadingInputViews: true)
                }
                cachedKeyboardTypes.removeAll()
            }
        }
    }
    
    
    // MARK: - Private properties
    
    private var numberBar: KeyboardNumberBar?
    
    private var cachedKeyboardTypes: [UIView: UIKeyboardType] = [:]
    
    private var activeTextControl: /*UITextInput && */ UIView? {
        didSet {
            if activeTextControl == oldValue { return }
            
            let keyboardAppearancePath = #keyPath(UITextInputTraits.keyboardAppearance)
            oldValue?.removeObserver(self, forKeyPath: keyboardAppearancePath, context: &keyboardAppearanceContext)
            activeTextControl?.addObserver(self, forKeyPath: keyboardAppearancePath, context: &keyboardAppearanceContext)
        }
    }
    
    
    // MARK: - Initializers
    
    private override init() {
        
        super.init()
        
        let notificationCenter = NotificationCenter.default
        let beginSelector = #selector(textControlWillBeginEditing(_:))
        let endSelector   = #selector(textControlDidEndEditing(_:))
        
        notificationCenter.addObserver(self, selector: beginSelector, name: NSNotification.Name(rawValue: "MPOL_UITextViewTextWillBeginEditingNotification"), object: nil)
        notificationCenter.addObserver(self, selector: beginSelector, name: .UITextFieldTextDidBeginEditing, object: nil)
        notificationCenter.addObserver(self, selector: endSelector,   name: .UITextViewTextDidEndEditing, object: nil)
        notificationCenter.addObserver(self, selector: endSelector,   name: .UITextFieldTextDidEndEditing, object: nil)
        
        UserDefaults.mpol.addObserver(self, forKeyPath: isNumberBarEnabledKey, context: &isNumberBarEnabledContext)
    }
    
    
    deinit {
        activeTextControl?.removeObserver(self, forKeyPath: #keyPath(UITextInputTraits.keyboardAppearance), context: &keyboardAppearanceContext)
        UserDefaults.mpol.removeObserver(self, forKeyPath: isNumberBarEnabledKey, context: &isNumberBarEnabledContext)
    }
    
    
    // MARK: - Overrides
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &keyboardAppearanceContext {
            if let numberBar = self.numberBar,
                (object as? UIView)?.inputAccessoryView == numberBar,
                let appearance = (object as? UITextInputTraits)?.keyboardAppearance {
                numberBar.keyboardAppearance = appearance
            }
        } else if context == &isNumberBarEnabledContext {
            isNumberBarEnabled = UserDefaults.mpol.bool(forKey: isNumberBarEnabledKey)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    
    // MARK: - Notifications
    
    @objc private func textControlWillBeginEditing(_ notification: NSNotification) {
        guard let control = notification.object as? UIView, control is UITextInput else { return }
        
        activeTextControl = control
        if isNumberBarEnabled {
            applyNumberBar(to: control, reloadingInputViews: false)
        }
    }
    
    
    @objc private func textControlDidEndEditing(_ notification: NSNotification) {
        guard let control = notification.object as? UIView, control is UITextInput else { return }
        
        if activeTextControl == control {
            activeTextControl = nil
        }
    }
    
    
    
    // MARK: - Number bar install/remove methods
    
    private func applyNumberBar(to view: UIView, reloadingInputViews: Bool) {
        if isNumberBarEnabled == false || view.inputAccessoryView != nil { return }
        
        let useNumberBar: Bool
        if let textView = view as? UITextView {
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
                let numberBar: KeyboardNumberBar
                if let currentBar = self.numberBar {
                    numberBar = currentBar
                } else {
                    numberBar = KeyboardNumberBar()
                    self.numberBar = numberBar
                }
                
                textView.inputAccessoryView = numberBar
                numberBar.textInputView     = textView
            }
        } else if let textField = view as? UITextField {
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
                let numberBar: KeyboardNumberBar
                if let currentBar = self.numberBar {
                    numberBar = currentBar
                } else {
                    numberBar = KeyboardNumberBar()
                    self.numberBar = numberBar
                }
                
                textField.inputAccessoryView = numberBar
                numberBar.textInputView      = textField
            }
        }
        if reloadingInputViews {
            view.reloadInputViews()
        }
    }
    
    
    private func removeNumberBar(from view: UIView, reloadingInputViews: Bool) {
        if numberBar == nil || view.inputAccessoryView != numberBar {
            return
        }
        
        let cachedKeyboardType = cachedKeyboardTypes.removeValue(forKey: view)
        
        if let textView = view as? UITextView {
            textView.inputAccessoryView = nil
            if let cachedKeyboardType = cachedKeyboardType {
                textView.keyboardType = cachedKeyboardType
            }
        } else if let textField = view as? UITextField {
            textField.inputAccessoryView = nil
            if let cachedKeyboardType = cachedKeyboardType {
                textField.keyboardType = cachedKeyboardType
            }
        }
        
        if reloadingInputViews {
            view.reloadInputViews()
        }
    }
    
}
