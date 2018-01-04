//
//  File.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public struct EnlargeStyle: CellSelectionAnimatable {
    public func configure(_ cell: CollectionViewFormCell) {
        let isSelected = cell.isSelected
        let isHighlighted = cell.isHighlighted

        let contentView = cell.contentView
        UIView.animate(withDuration: 0.3, animations: {
            let isFocus = isSelected || isHighlighted
            let transform = isFocus ? CGAffineTransform(scaleX: 1.05, y: 1.05) : CGAffineTransform.identity
            contentView.transform = transform
            cell.layer.zPosition = isFocus ? 1 : 0
            cell.layer.shadowOffset = isFocus ? CGSize(width: -10, height: 10) : CGSize.zero
            cell.layer.shadowRadius = isFocus ? 5 : 0
            cell.layer.shadowOpacity = isFocus ? 0.1 : 0
        })

        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil
        let finalColor = validationColor ?? cell.separatorColor
        cell.separatorView.backgroundColor = finalColor
    }
}
