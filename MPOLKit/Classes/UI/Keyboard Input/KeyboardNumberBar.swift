//
//  KeyboardNumberBar.swift
//  MPOL-UI
//
//  Created by Rod Brown on 7/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit


/// An input accessory view for the keyboard to show an additional row of keyboard keys
/// above a standard iOS keyboard.
///
/// You should generally not need to create a keyboard number bar directly. Instead,
/// use the shared `KeyboardInputManager` instance to apply the number bar globally.
/// In cases where you want a number bar irresepctive of whether the global bar is
/// enabled, create and set one directly as its `inputAccessoryView`.
public class KeyboardNumberBar: UIInputView {
    
    /// The text input view the number bar should forward text entry events towards.
    public weak var textInputView: UITextInput? {
        didSet {
            if let appearance = textInputView?.keyboardAppearance {
                self.keyboardAppearance = appearance
            }
        }
    }
    
    /// The keyboard appearance the keyboard should mim
    public var keyboardAppearance: UIKeyboardAppearance = .light {
        didSet {
            if (oldValue == .dark) != (keyboardAppearance == .dark) {
                updateKeyboardAppearance()
            }
        }
    }
    
    fileprivate let keys:    [String]
    fileprivate let buttons: [UIButton]
    
    fileprivate static let lightButtonImage         = newButtonImage(forDarkTheme: false, selected: false)
    fileprivate static let lightButtonSelectedImage = newButtonImage(forDarkTheme: false, selected: true)
    fileprivate static let darkButtonImage          = newButtonImage(forDarkTheme: true,  selected: false)
    fileprivate static let darkButtonSelectedImage  = newButtonImage(forDarkTheme: true,  selected: true)
    
    
    // MARK: - Initializers
    
    public init() {
        func newButton(_ index: Int, text: String) -> UIButton {
            let button = UIButton(type: .custom)
            
            var accessibilityTrait = button.accessibilityTraits
            accessibilityTrait &= ~UIAccessibilityTraitButton
            accessibilityTrait |= UIAccessibilityTraitKeyboardKey
            accessibilityTrait |= UIAccessibilityTraitPlaysSound
            button.accessibilityTraits = accessibilityTrait
            
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
    
    
    /// `KeyboardNumberBar` does not support NSCoding.
    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("KeyboardNumberBar does not support NSCoding.")
    }
    
}

extension KeyboardNumberBar: UIInputViewAudioFeedback {
    
    /// Enables keyboard clicks. This always returns `true` for `KeyboardNumberBar`.
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
    
    fileprivate func updateKeyboardAppearance() {
        let light = keyboardAppearance != .dark
        let titleColor: UIColor = light ? .black : .white
        let image = light ? KeyboardNumberBar.lightButtonImage : KeyboardNumberBar.darkButtonImage
        let selectedImage: UIImage? = light ? KeyboardNumberBar.lightButtonSelectedImage : nil
        
        for button in buttons {
            button.setTitleColor(titleColor,         for: .normal)
            button.setBackgroundImage(image,         for: .normal)
            button.setBackgroundImage(selectedImage, for: .highlighted)
        }
    }
    
    fileprivate class func newButtonImage(forDarkTheme dark: Bool, selected: Bool) -> UIImage {
        // We don't use a more generic method because we want to add shadow, and we want a specific
        // shadow without any blur. 
        
        func drawButtonImage(in context: CGContext) {
            // These colors are to match the keyboard and are tested matches for standard system keys.
            // They're not really relevant for themes.
            let color: UIColor
            let shadowColor: UIColor
            if dark {
                color = selected ? #colorLiteral(red: 0.2078169286, green: 0.2078586221, blue: 0.2078110874, alpha: 1) : #colorLiteral(red: 0.3529005945, green: 0.3529652059, blue: 0.3528915048, alpha: 1)
                shadowColor = #colorLiteral(red: 0.02352941176, green: 0.02352941176, blue: 0.02352941176, alpha: 1)
            } else {
                color = selected ? #colorLiteral(red: 0.6823529412, green: 0.7019607843, blue: 0.7450980392, alpha: 1) : .white
                shadowColor = #colorLiteral(red: 0.537254902, green: 0.5450510979, blue: 0.5607843137, alpha: 1)
            }
            
            context.addPath(CGPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: 9.0, height: 9.0), cornerWidth: 4.0, cornerHeight: 4.0, transform: nil))
            context.setShadow(offset: CGSize(width: 0.0, height: 1.0), blur: 0.0, color: shadowColor.cgColor)
            
            color.setFill()
            context.fillPath()
        }
        
        let image: UIImage
        let imageSize = CGSize(width: 9.0, height: 10.0)
        
        if #available(iOS 10, *) {
            let imageRenderer = UIGraphicsImageRenderer(size: imageSize)
            image = imageRenderer.image { (_: UIGraphicsImageRendererContext) in
                if let context = UIGraphicsGetCurrentContext() {
                    drawButtonImage(in: context)
                }
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            if let context = UIGraphicsGetCurrentContext() {
                drawButtonImage(in: context)
            }
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 5.0, right: 4.0), resizingMode: .stretch)
    }
    
}
