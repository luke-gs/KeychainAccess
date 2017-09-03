//
//  SearchCollectionViewCell.swift
//  Pods
//
//  Created by Valery Shorinov on 29/3/17.
//
//

import UIKit


internal class SearchFieldCollectionViewCell: CollectionViewFormCell {
    
    private static let preferredSeparatorWidth: CGFloat = 480.0
    private static let minimumForPreferredSeparatorWidth: CGFloat = 500.0
    
    public static var cellContentHeight: CGFloat { return 64.0 }
    
    
    // MARK: - Properties
    
    public let textField = UITextField(frame: .zero)
    
    public override var frame: CGRect {
        didSet {
            if frame.width != oldValue.width {
                updateSeparatorInsets()
            }
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            if bounds.width != oldValue.width {
                updateSeparatorInsets()
            }
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected && oldValue == false && textField.isEnabled {
                _ = textField.becomeFirstResponder()
            } else if !isSelected && oldValue == true && textField.isFirstResponder {
                _ = textField.resignFirstResponder()
            }
        }
    }
    
    public var additionalButtons: [UIButton]? {
        didSet {
            oldValue?.forEach({ (button) in
                button.removeFromSuperview()
            })
            
            additionalButtons?.forEach({ (button) in
                button.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
                button.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
                buttonStackView.addArrangedSubview(button)
            })
        }
    }
    
    private let buttonStackView = UIStackView(frame: .zero)
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    internal override func commonInit() {
        super.commonInit()
        
        selectionStyle = .underline
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font          = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        textField.textColor     = .darkGray
        textField.textAlignment = .center
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""),
                                                             attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.lightGray])
       
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 18.0
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = self.contentView
        contentView.addSubview(textField)
        contentView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, priority: UILayoutPriorityDefaultHigh),
            NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, constant: 3.0),
            NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leadingMargin, priority: UILayoutPriorityDefaultHigh),
            
            NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: textField, attribute: .trailing, constant: 5.0, priority: UILayoutPriorityDefaultHigh + 1),
            NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin),
            NSLayoutConstraint(item: buttonStackView, attribute: .centerY, relatedBy: .equal, toItem: textField, attribute: .centerY),
            NSLayoutConstraint(item: buttonStackView, attribute: .height, relatedBy: .equal, toConstant: 28),
            
            NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .centerX, constant: SearchFieldCollectionViewCell.preferredSeparatorWidth / 2.0, priority: UILayoutPriorityDefaultHigh)
        ])
        
        updateSeparatorInsets()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: .UITextFieldTextDidBeginEditing, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing(_:)),   name: .UITextFieldTextDidEndEditing,   object: textField)
        
        accessibilityLabel  = NSLocalizedString("Search", comment: "Accessibility")
        accessibilityTraits |= UIAccessibilityTraitSearchField
    }
    
    public override var accessibilityValue: String? {
        get { return textField.text }
        set { }
    }
    
    public override class func heightForValidationAccessory(withText text: String, contentWidth: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        
        let preferredContentWidth = contentWidth < SearchFieldCollectionViewCell.minimumForPreferredSeparatorWidth ? contentWidth : SearchFieldCollectionViewCell.preferredSeparatorWidth
        return super.heightForValidationAccessory(withText: text, contentWidth: preferredContentWidth, compatibleWith: traitCollection)
    }
    
    // MARK: - Private methods
    
    @objc private func textFieldDidBeginEditing(_ notification: NSNotification) {
        guard isSelected == false else { return }
        
        self.isSelected = true
    }
    
    @objc private func textFieldDidEndEditing(_ notification: NSNotification) {
        guard isSelected else { return }
        
        self.isSelected = false
    }
    
    private func updateSeparatorInsets() {
        let width = bounds.width
        if width < SearchFieldCollectionViewCell.minimumForPreferredSeparatorWidth {
            customSeparatorInsets = nil
        } else {
            let widthInset = ((width - SearchFieldCollectionViewCell.preferredSeparatorWidth) / 2.0)
            customSeparatorInsets = UIEdgeInsets(top: 0.0, left: widthInset, bottom: 0.0, right: widthInset)
        }
    }
    
}

