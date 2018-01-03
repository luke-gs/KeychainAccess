//
//  SearchCollectionViewCell.swift
//  Pods
//
//  Created by Valery Shorinov on 29/3/17.
//
//

import UIKit


class SearchFieldCollectionViewCell: CollectionViewFormCell {
    
    public static let preferredWidth: CGFloat = 512.0
    
    public static var cellContentHeight: CGFloat { return 64.0 }
    
    
    // MARK: - Properties
    
    public let textField = UITextField(frame: .zero)

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
                button.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
                button.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
                buttonStackView.addArrangedSubview(button)
            })
        }
    }
    
    private let buttonStackView = UIStackView(frame: .zero)

    internal override func commonInit() {
        super.commonInit()
        
        selectionStyle = .animated(style: .underline)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 28.0, weight: UIFont.Weight.bold)
        textField.textColor = .darkGray
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        textField.enablesReturnKeyAutomatically = true
        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""),
                                                             attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
       
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 18.0
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = self.contentView
        contentView.addSubview(textField)
        contentView.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, constant: 3.0),
            NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading),
            
            NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: textField, attribute: .trailing, constant: 5.0, priority: .defaultHigh + 1),
            NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing),
            NSLayoutConstraint(item: buttonStackView, attribute: .centerY, relatedBy: .equal, toItem: textField, attribute: .centerY),
            NSLayoutConstraint(item: buttonStackView, attribute: .height, relatedBy: .equal, toConstant: 28),

        ])

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: .UITextFieldTextDidBeginEditing, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing(_:)),   name: .UITextFieldTextDidEndEditing,   object: textField)
        
        accessibilityLabel  = NSLocalizedString("Search", comment: "Accessibility")
        accessibilityTraits |= UIAccessibilityTraitSearchField
    }
    
    public override var accessibilityValue: String? {
        get { return textField.text }
        set { }
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

}

