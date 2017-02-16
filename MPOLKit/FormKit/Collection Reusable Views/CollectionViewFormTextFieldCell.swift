//
//  CollectionViewFormTextFieldCell.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

private var textContext = 1

open class CollectionViewFormTextFieldCell: CollectionViewFormCell {
    
    public static let fonts = (UIFont.systemFont(ofSize: 14.5, weight: UIFontWeightSemibold), UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightSemibold))
    
    fileprivate static let interLabelSeparation: CGFloat = 2.0
    
    
    /// The title label for the cell. This sits directly above the text field.
    open let titleLabel = UILabel(frame: .zero)
    
    /// The text field for the cell.
    open let textField = FormTextField(frame: .zero)
    
    fileprivate var textFieldHeight: CGFloat = 20.0
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet {
            if isSelected { _ = textField.becomeFirstResponder() }
        }
    }
    
    /// The content mode for the cell.
    /// This causes the cell to re-layout its content with the requested content parameters,
    /// in the vertical dimension.
    /// - note: Currently supports only .Top or .Center
    open override var contentMode: UIViewContentMode {
        didSet {
            if contentMode != oldValue { setNeedsLayout() }
        }
    }
    
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel.font = CollectionViewFormTextFieldCell.fonts.0
        textField.font  = CollectionViewFormTextFieldCell.fonts.1
        textField.clearButtonMode = .whileEditing
        
        let contentView = self.contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: [], context: &textContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), options: [], context: &textContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), options: [], context: &textContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines),  options: [], context: &textContext)
        textField.addObserver(self, forKeyPath: #keyPath(UITextField.font), options: [], context: &textContext)
    }
    
    deinit {
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &textContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &textContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &textContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines), context: &textContext)
        textField.removeObserver(self, forKeyPath: #keyPath(UITextField.font), context: &textContext)
    }
    
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let contentView = self.contentView
        
        let contentBounds    = contentView.bounds
        let contentInsets    = contentView.layoutMargins
        let contentLeftInset = contentInsets.left
        
        let availableWidth   = contentBounds.width  - contentLeftInset  - contentInsets.right
        
        let titleSize        = titleLabel.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        var textFieldHeight  = self.textFieldHeight
        
        var currentYOffset: CGFloat
        
        if contentMode == .center {
            let heightForContent = titleSize.height + textFieldHeight + (titleSize.height.isZero == false && textFieldHeight.isZero == false ? CollectionViewFormTextFieldCell.interLabelSeparation : 0.0)
            let availableContentHeight = contentBounds.height - contentInsets.top - contentInsets.bottom
            currentYOffset = (contentInsets.top + max((availableContentHeight - heightForContent) / 2.0, 0.0)).rounded(toScale: window?.screen.scale ?? 1.0)
        } else {
            currentYOffset = contentInsets.top + 4.0
        }
        
        titleLabel.frame = CGRect(origin: CGPoint(x: contentLeftInset, y: currentYOffset), size: titleSize)
        currentYOffset += ceil(titleSize.height)
        if titleSize.height.isZero == false && textFieldHeight.isZero == false { currentYOffset += CollectionViewFormTextFieldCell.interLabelSeparation }
        
        textFieldHeight = max(0.0, min(textFieldHeight, contentBounds.height - currentYOffset))
        textField.frame = CGRect(x: contentLeftInset, y: currentYOffset, width: availableWidth, height: textFieldHeight)
    }
    
    
    // MARK: - KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            if object as? NSObject == textField {
                textFieldHeight = ceil(textField.intrinsicContentSize.height)
            }
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

