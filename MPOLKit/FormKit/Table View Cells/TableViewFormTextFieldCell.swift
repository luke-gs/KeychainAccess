//
//  TableViewFormTextFieldCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 13/09/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import Foundation

open class TableViewFormTextFieldCell: UITableViewCell {
    
    open let titleLabel: UILabel = UILabel(frame: .zero)
    
    open let textField: FormTextField = FormTextField(frame: .zero)
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected { _ = textField.becomeFirstResponder() }
    }
    
}

fileprivate extension TableViewFormTextFieldCell {
    
    func commonInit() {
        selectionStyle = .none
        
        let contentView = self.contentView
        
        titleLabel.font = .systemFont(ofSize: 14.5, weight: UIFontWeightSemibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textField.font  = .systemFont(ofSize: 16.0, weight: UIFontWeightSemibold)
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        let layoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(layoutGuide)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: layoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin),
            NSLayoutConstraint(item: layoutGuide, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins),
            NSLayoutConstraint(item: layoutGuide, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin),
            NSLayoutConstraint(item: layoutGuide, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .topMargin),

            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: layoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom),
            NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: layoutGuide, attribute: .bottom),
            NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: layoutGuide, attribute: .trailing)
        ])
    }
    
}
