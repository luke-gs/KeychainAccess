//
//  CollectionViewFormRoundedRectButtonCell.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// A cell that contains a centred `RoundedRectButton`
open class CollectionViewFormRoundedRectButtonCell: CollectionViewFormCell {
    
    open let button = RoundedRectButton()
    
    open override func commonInit() {
        super.commonInit()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
