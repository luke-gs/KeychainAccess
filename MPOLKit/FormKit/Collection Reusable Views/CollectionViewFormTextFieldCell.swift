//
//  CollectionViewFormTextFieldCell.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

open class CollectionViewFormTextFieldCell: CollectionViewFormCell {
    
    fileprivate static let interLabelSeparation: CGFloat = 2.0
    
    
    /// The title label for the cell. This sits directly above the text field.
    open let titleLabel = UILabel(frame: .zero)
    
    
    /// The text field for the cell.
    open let textField = FormTextField(frame: .zero)
    
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet { if isSelected && oldValue == false { _ = textField.becomeFirstResponder() } }
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
        textField.clearButtonMode = .whileEditing
        
        let contentView            = self.contentView
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, constant: CollectionViewFormTextFieldCell.interLabelSeparation),
            NSLayoutConstraint(item: textField, attribute: .leading,  relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textField, attribute: .bottom,   relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .bottom),
        ])
    }
    
}


internal extension CollectionViewFormTextFieldCell {
    
    internal override func applyStandardFonts() {
        titleLabel.font = CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
        textField.font  = CollectionViewFormDetailCell.font(withEmphasis: true,  compatibleWith: traitCollection)
        
        titleLabel.adjustsFontForContentSizeCategory = true
        textField.adjustsFontForContentSizeCategory  = true
    }
    
}

