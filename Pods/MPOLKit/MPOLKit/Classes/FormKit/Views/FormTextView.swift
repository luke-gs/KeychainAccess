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
    
    fileprivate var minimumHeightConstraint: NSLayoutConstraint!
    
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
        
        backgroundColor = .clear
        
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .gray
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaceholderAppearance), name: .UITextViewTextDidChange, object: self)
        
        let minimumHeight = (font?.lineHeight ?? 17.0).ceiled(toScale: (window?.screen ?? .main).scale)
        minimumHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toConstant: minimumHeight)
    }
    
    deinit {
        placeholderLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
    }

}


extension FormTextView {
    
    open override var text: String? {
        didSet {
            updatePlaceholderAppearance()
        }
    }
    
    open override var attributedText: NSAttributedString? {
        didSet {
            updatePlaceholderAppearance()
        }
    }
    
    open override var font: UIFont? {
        didSet {
            updateMinimumHeightConstraint()
            setNeedsLayout()
        }
    }
    
    open override var textContainerInset: UIEdgeInsets {
        didSet { setNeedsLayout() }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let displayScale = (window?.screen ?? .main).scale
        
        guard let textFont = font ?? placeholderLabel.font, let placeholderFont = placeholderLabel.font ?? font else { return }
        
        // layout the placeholder
        bringSubview(toFront: placeholderLabel)
        
        let textContainerInset = self.textContainerInset
        
        let firstBaselineY = textFont.ascender + textContainerInset.top
        let placeholderBaselineY = placeholderFont.ascender
        
        let placeholderOrigin = CGPoint(x: (textContainerInset.left + 5.0).rounded(toScale: displayScale), y: (firstBaselineY - placeholderBaselineY).rounded(toScale: displayScale))
        var placeholderSize = placeholderLabel.sizeThatFits(.max)
        placeholderSize.width = min(placeholderSize.width, max(bounds.size.width - 9.0 - textContainerInset.left - textContainerInset.right, 0.0)).floored(toScale: displayScale)
        
        placeholderLabel.frame = CGRect(origin: placeholderOrigin, size: placeholderSize)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateMinimumHeightConstraint()
        setNeedsLayout()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}


fileprivate extension FormTextView {
    
    @objc fileprivate func updatePlaceholderAppearance() {
        placeholderLabel.isHidden = (text?.isEmpty ?? true) == false
    }
    
    @objc fileprivate func updateMinimumHeightConstraint() {
        let minimumHeight = (font?.lineHeight ?? 17.0).ceiled(toScale: (window?.screen ?? .main).scale)
        
        if minimumHeightConstraint.constant !=~ minimumHeight {
            minimumHeightConstraint.constant = minimumHeight
        }
    }
    
}
