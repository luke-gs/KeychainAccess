//
//  SearchFieldAdvanceCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 22/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


class SearchFieldAdvanceCell: CollectionViewFormCell {
    public static var cellContentHeight: CGFloat { return 64.0 }

    public let actionButton = UIButton(type: .system)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
 
    override func commonInit() {
        super.commonInit()

        separatorStyle = .none
        selectionStyle = .none

        actionButton.setTitleColor(.black, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 11.0, weight: UIFont.Weight.semibold)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: actionButton, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leadingMargin, multiplier: 1.0, priority: UILayoutPriority.defaultHigh),
            NSLayoutConstraint(item: actionButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .topMargin, multiplier: 1.0, priority: UILayoutPriority.defaultHigh),
            NSLayoutConstraint(item: actionButton, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottomMargin, multiplier: 1.0, priority: UILayoutPriority.defaultHigh),
            NSLayoutConstraint(item: actionButton, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin, multiplier: 1.0, priority: UILayoutPriority.defaultHigh),
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    public override var accessibilityValue: String? {
        get { return actionButton.title(for: .normal) }
        set {}
    }
}
