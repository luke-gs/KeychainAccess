//
//  FormTextField.swift
//  MPOLKit
//
//  Created by Rod Brown on 18/08/2016.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

open class FormTextField: UITextField {
    
    // MARK: - Public properties
    
    public var unitLabel: UILabel {
        if let unitLabel = _unitLabel { return unitLabel }
        
        let unitLabel = UILabel(frame: .zero)
        unitLabel.textColor = textColor
        unitLabel.font      = font
        unitLabel.isHidden  = true
        _unitLabel = unitLabel
        return unitLabel
    }
    
    @NSCopying public var placeholderFont: UIFont? {
        didSet { updatePlaceholder() }
    }
    
    @NSCopying public var placeholderTextColor: UIColor? {
        didSet { if placeholderTextColor != oldValue { updatePlaceholder() } }
    }
    
    
    // MARK: - Private properties
    
    private var placeholderText: String? {
        didSet { if placeholderText != oldValue { updatePlaceholder() }}
    }
    
    private var _unitLabel: UILabel? {
        didSet {
            oldValue?.removeFromSuperview()
            if let newLabel = _unitLabel {
                addSubview(newLabel)
            }
            
            keyPathsAffectingLabelLayout.forEach {
                oldValue?.removeObserver(self, forKeyPath: $0, context: &kvoContext)
                _unitLabel?.addObserver(self, forKeyPath: $0, context: &kvoContext)
            }
            setNeedsLayout()
        }
    }
    
    private var singleSpaceWidth: CGFloat = 0.0
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        
        if let font = self.font {
            singleSpaceWidth = (" " as NSString).boundingRect(with: .zero, attributes: [NSFontAttributeName: font], context: nil).width
        }
    }
    
    deinit {
        keyPathsAffectingLabelLayout.forEach {
            _unitLabel?.removeObserver(self, forKeyPath: $0, context: &kvoContext)
        }
    }
    
    
    // MARK: - Overrides
    
    open override var font: UIFont? {
        didSet {
            guard let font = self.font, let unitLabel = _unitLabel else { return }
            
            if font != unitLabel.font {
                unitLabel.font = font
                singleSpaceWidth = (" " as NSString).boundingRect(with: .zero, attributes: [NSFontAttributeName: font], context: nil).width
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let unitLabel = _unitLabel else { return }
        
        let isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        let hidden = unitLabel.text?.isEmpty ?? true || text?.isEmpty ?? true
        unitLabel.isHidden = hidden
        
        if hidden { return }
            
        let bounds = self.bounds
        let displayScale = traitCollection.currentDisplayScale
        let maxTextRect = self.textRect(forBounds: bounds)
        
        let valueInset: CGFloat
        if isEditing, let textRange = self.textRange(from: beginningOfDocument, to: endOfDocument) {
            // get the text rectangle and fix for the fact it's offset by the maxTextRect origin.
            var textRect = firstRect(for: textRange)
            textRect.origin.x += maxTextRect.origin.x
            
            // work out the intersection - only the text rect where its in the text max bounds
            textRect = textRect.intersection(maxTextRect)
            textRect = textRect.integral
            
            if isRightToLeft {
                valueInset = (bounds.width - textRect.minX + singleSpaceWidth).floored(toScale: displayScale)
            } else {
                valueInset = (textRect.maxX + singleSpaceWidth).ceiled(toScale: displayScale)
            }
        } else if let text = self.text?.ifNotEmpty() {
            let textWidth = text.boundingRect(with: .max, attributes:  [NSFontAttributeName: self.font ?? .systemFont(ofSize: UIFont.systemFontSize)] , context: nil).width
            
            if isRightToLeft {
                valueInset = (bounds.width - maxTextRect.maxX + ceil(min(textWidth, maxTextRect.width)) + singleSpaceWidth).ceiled(toScale: displayScale)
            } else {
                valueInset = (maxTextRect.minX + ceil(min(textWidth, maxTextRect.width)) + singleSpaceWidth).floored(toScale: displayScale)
            }
        } else {
            valueInset = singleSpaceWidth.ceiled(toScale: displayScale)
        }
        
        let availableTextWidth = bounds.width - valueInset
        var unitLabelSize = unitLabel.sizeThatFits(CGSize(width: availableTextWidth, height: .greatestFiniteMagnitude))
        unitLabelSize.width = min(unitLabelSize.width, availableTextWidth)
        
        unitLabel.frame = CGRect(origin: CGPoint(x: (isRightToLeft ? bounds.width - valueInset - unitLabelSize.width : valueInset).rounded(toScale: displayScale),
                                                 y: (maxTextRect.minY + (font?.ascender ?? 0.0) - (unitLabel.font?.ascender ?? 0.0)).rounded(toScale: displayScale)),
                                 size: unitLabelSize)
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedTextRect(super.textRect(forBounds: bounds))
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedTextRect(super.editingRect(forBounds: bounds))
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // The font autoupdate reverts fonts to the standard placeholder font (the same as the content).
        // To retain the current one, we need to update the font. With the scaled if possible,
        // or the old one if not.
        if adjustsFontForContentSizeCategory && traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            if let placeholderFontType = placeholderFont?.fontDescriptor.fontAttributes["NSCTFontUIUsageAttribute"] as? String {
                placeholderFont = .preferredFont(forTextStyle: UIFontTextStyle(rawValue: placeholderFontType), compatibleWith: traitCollection)
            } else {
                let currentFont = placeholderFont
                self.placeholderFont = currentFont
            }
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
    
    private func adjustedTextRect(_ rect: CGRect) -> CGRect {
        if _unitLabel?.isHidden ?? true { return rect }
        
        var adjustedRect = rect
        
        // Calculate the preferred area reserved for our unit label.
        var inset = (_unitLabel?.frame.width ?? 0.0) + singleSpaceWidth.ceiled(toScale: traitCollection.currentDisplayScale)
        
        // Don't allow the adjustment to be any greater than 10 points from taking the
        // whole space - we need *some* room to type!
        inset = min(adjustedRect.width - 10.0, inset)
        
        // Adjust the rect accordingly
        adjustedRect.size.width -= inset
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            adjustedRect.origin.x += inset
        }
        
        return adjustedRect
    }
    
    private func updatePlaceholder() {
        if let placeholder = placeholderText?.ifNotEmpty() {
            let attributes = [NSFontAttributeName: self.placeholderFont ?? UIFont.systemFont(ofSize: 15.0), NSForegroundColorAttributeName: self.placeholderTextColor ?? .lightGray]
            super.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        } else {
            super.attributedPlaceholder = nil
        }
    }
    
}
