//
//  UnderlineStyle.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class UnderlineStyle: CellSelectionAnimatable {
    public class func configure(_ cell: CollectionViewFormCell) {
        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil

        let separatorView = cell.separatorView
        let wantsUnderline = cell.isSelected

        let finalColor = validationColor ?? (wantsUnderline ? separatorView.tintColor : cell.separatorColor)
        separatorView.backgroundColor = finalColor
        if (separatorView.bounds.height >~ 1.0) != wantsUnderline {
            cell.setNeedsLayout()
        }
    }

    public init() {}
}
