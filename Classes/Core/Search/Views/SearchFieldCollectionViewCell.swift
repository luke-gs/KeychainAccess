//
//  SearchCollectionViewCell.swift
//  Pods
//
//  Created by Valery Shorinov on 29/3/17.
//
//

import UIKit


public class SearchFieldCollectionViewCell: CollectionViewFormCell {
    
    public static var cellContentHeight: CGFloat { return 23.0 }
    
    
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
        
        let stackTrailingConstraint = NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .centerX, constant: 480.0 / 2.0)
        stackTrailingConstraint.priority = UILayoutPriorityDefaultHigh
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX),
            NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, constant: 3.0),
            NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leadingMargin),
            
            NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: textField, attribute: .trailing, constant: 5.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin),
            NSLayoutConstraint(item: buttonStackView, attribute: .centerY, relatedBy: .equal, toItem: textField, attribute: .centerY),
            NSLayoutConstraint(item: buttonStackView, attribute: .height, relatedBy: .equal, toConstant: 28),
            
            stackTrailingConstraint
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
    
    
    // MARK: - Private methods
    
    @objc private func textFieldDidBeginEditing(_ notification: NSNotification) {
        guard isSelected == false,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    @objc private func textFieldDidEndEditing(_ notification: NSNotification) {
        guard isSelected,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    private func updateSeparatorInsets() {
        let width = bounds.width
        if width < 500.0 {
            customSeparatorInsets = nil
        } else {
            let widthInset = ((width - 480.0) / 2.0)
            customSeparatorInsets = UIEdgeInsets(top: 0.0, left: widthInset, bottom: 0.0, right: widthInset)
        }
    }
    
}

protocol SearchCollectionViewCellDelegate: class {
    
    func searchCollectionViewCell(_ cell: SearchFieldCollectionViewCell, didChangeText text: String?)
    
    func searchCollectionViewCell(_ cell: SearchFieldCollectionViewCell, didSelectSegmentAt index: Int)
}
