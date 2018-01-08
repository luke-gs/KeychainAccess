//
//  FadeStyle.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class FadeStyle: CellSelectionAnimatable {
    public func configure(_ cell: CollectionViewFormCell) {
        let isSelected = cell.isSelected
        let isHighlighted = cell.isHighlighted

        let alpha: CGFloat = isSelected || isHighlighted ? 0.5 : 1.0

        // Don't set unless necessary to avoid interfering with inflight animations.
        if cell.contentView.alpha !=~ alpha {
            cell.contentView.alpha = alpha
        }

        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil
        let finalColor = validationColor ?? cell.separatorColor
        cell.separatorView.backgroundColor = finalColor
    }

    public init() {}
}
