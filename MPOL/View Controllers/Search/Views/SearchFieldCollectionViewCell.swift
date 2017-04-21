//
//  SearchCollectionViewCell.swift
//  Pods
//
//  Created by Valery Shorinov on 29/3/17.
//
//

import UIKit
import MPOLKit


class SearchFieldCollectionViewCell: CollectionViewFormCell {
    
    static var cellContentHeight: CGFloat { return 23.0 }
    
    
    // MARK: - Properties
    
    let textField = UITextField(frame: .zero)
    
    override var frame: CGRect {
        didSet {
            if frame.width != oldValue.width {
                updateSeparatorInsets()
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if bounds.width != oldValue.width {
                updateSeparatorInsets()
            }
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected && textField.isEnabled {
                textField.becomeFirstResponder()
            }
        }
    }
    
    
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
        selectionStyle = .underline
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font          = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        textField.textColor     = .darkGray
        textField.textAlignment = .center
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 12.0
        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""),
                                                             attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.lightGray])
       
        let contentView = self.contentView
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX),
            NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, constant: 3.0),
            NSLayoutConstraint(item: textField, attribute: .width,   relatedBy: .greaterThanOrEqual, toConstant: 480.0, priority: UILayoutPriorityDefaultHigh),
            NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leadingMargin)
        ])
        
        updateSeparatorInsets()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: .UITextFieldTextDidBeginEditing, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing(_:)),   name: .UITextFieldTextDidEndEditing,   object: textField)
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
