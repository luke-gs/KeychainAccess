//
//  FormTextView.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

open class FormTextView: UITextView {

    open let placeholderLabel: UILabel = UILabel(frame: .zero)
    
    private var isRightToLeft: Bool = false {
        didSet {
            if isRightToLeft != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        super.textContainerInset = .zero
        
        if #available(iOS 10, *) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        }
        
        backgroundColor = .clear
        
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .gray
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        addSubview(placeholderLabel)
        
        alwaysBounceVertical = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaceholderAppearance), name: .UITextViewTextDidChange, object: self)
    }
    
    deinit {
        placeholderLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override var text: String? {
        didSet { updatePlaceholderAppearance() }
    }
    
    open override var attributedText: NSAttributedString? {
        didSet { updatePlaceholderAppearance() }
    }
    
    open override var textContainerInset: UIEdgeInsets {
        didSet { setNeedsLayout() }
    }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if semanticContentAttribute == oldValue { return }
            
            if #available(iOS 10, *) {
                isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
            } else {
                isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // There are bugs in using auto layout on subviews on a UITextView, so we'll do the work here in layout subviews
        
        let displayScale = (window?.screen ?? .main).scale
        
        guard let textFont = font ?? placeholderLabel.font, let placeholderFont = placeholderLabel.font ?? font else { return }
        
        // layout the placeholder
        bringSubview(toFront: placeholderLabel)
        
        let textContainerInset = self.textContainerInset
        
        let firstBaselineY = textFont.ascender + textContainerInset.top
        let placeholderBaselineY = placeholderFont.ascender
        var placeholderSize = placeholderLabel.sizeThatFits(.max)
        
        placeholderSize.width = min(placeholderSize.width, max(bounds.size.width - 9.0 - textContainerInset.left - textContainerInset.right, 0.0)).floored(toScale: displayScale)
        
        var placeholderOrigin: CGPoint = CGPoint(x: 0.0, y: (firstBaselineY - placeholderBaselineY).rounded(toScale: displayScale))
            
        if isRightToLeft {
            placeholderOrigin.x = (bounds.width - textContainerInset.left - 5.0 - placeholderSize.width).rounded(toScale: displayScale)
        } else {
            placeholderOrigin.x = (textContainerInset.left + 5.0).rounded(toScale: displayScale)
        }
        placeholderLabel.frame = CGRect(origin: placeholderOrigin, size: placeholderSize)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 10, *) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Private methods
    
    @objc private func updatePlaceholderAppearance() {
        placeholderLabel.isHidden = (text?.isEmpty ?? true) == false
    }
    
}
