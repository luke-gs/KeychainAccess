//
//  SearchFieldAdvanceCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 22/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


public class SearchFieldAdvanceCell: CollectionViewFormCell {
    public static var cellContentHeight: CGFloat { return 23.0 }

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
        actionButton.titleLabel?.font = .systemFont(ofSize: 11.0, weight: UIFontWeightSemibold)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
            actionButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            actionButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    public override var accessibilityValue: String? {
        get { return actionButton.title(for: .normal) }
        set {}
    }
}
