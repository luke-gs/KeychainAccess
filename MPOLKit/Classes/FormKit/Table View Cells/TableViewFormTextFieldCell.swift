//
//  TableViewFormTextFieldCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 13/09/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1


open class TableViewFormTextFieldCell: TableViewFormCell {
    
    open let titleLabel: UILabel = UILabel(frame: .zero)
    
    open let textField: FormTextField = FormTextField(frame: .zero)
    
    fileprivate var titleDetailSeparationConstraint: NSLayoutConstraint!
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit() {
        selectionStyle = .none
        
        textField.clearButtonMode = .whileEditing
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = self.contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        titleDetailSeparationConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        
        let layoutGuide = contentModeLayoutGuide
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: layoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: textField, attribute: .leading,  relatedBy: .equal, toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: layoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textField, attribute: .bottom,   relatedBy: .equal, toItem: layoutGuide, attribute: .bottom, constant: 0.5),
            titleDetailSeparationConstraint
        ])
        
        
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    deinit {
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
}


extension TableViewFormTextFieldCell {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            let titleDetailSpace = titleLabel.text?.isEmpty ?? true ? 0.0 : CellTitleDetailSeparation
            
            if titleDetailSeparationConstraint.constant !=~ titleDetailSpace {
                titleDetailSeparationConstraint.constant = titleDetailSpace
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected { _ = textField.becomeFirstResponder() }
    }
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        titleLabel.font = CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
        textField.font  = CollectionViewFormDetailCell.font(withEmphasis: true,  compatibleWith: traitCollection)
        
        if #available(iOS 10, *) {
            textField.placeholderFont = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            textField.placeholderFont = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
}


// MARK: - Accessibility
/// Accessibility
extension TableViewFormTextFieldCell {
    
    dynamic open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return titleLabel.text
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
    dynamic open override var accessibilityValue: String? {
        get {
            if let setValue = super.accessibilityValue {
                return setValue
            }
            let text = textField.text
            if text?.isEmpty ?? true {
                return textField.placeholder
            }
            return text
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
    dynamic open override var isAccessibilityElement: Bool {
        get {
            if textField.isEditing { return false }
            return super.isAccessibilityElement
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }
    
}


