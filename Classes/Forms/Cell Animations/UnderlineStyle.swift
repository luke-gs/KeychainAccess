//
//  UnderlineStyle.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public struct UnderlineStyle: CellSelectionAnimatable {
    public func configure(_ cell: CollectionViewFormCell) {
        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil
        let finalColor = validationColor ?? cell.separatorColor
        cell.separatorView.backgroundColor = finalColor

        let wantsUnderline = cell.isSelected
        if (cell.separatorView.bounds.height >~ 1.0) != wantsUnderline {
            cell.setNeedsLayout()
        }
    }
}
