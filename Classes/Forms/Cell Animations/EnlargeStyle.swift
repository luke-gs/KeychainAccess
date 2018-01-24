//
//  File.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class EnlargeStyle: CellSelectionAnimatable {
    public static func configure(_ cell: CollectionViewFormCell, isFocused focused: Bool) {

        let transform = focused ? CGAffineTransform(scaleX: 1.05, y: 1.05) : CGAffineTransform.identity
        cell.transform = transform
        cell.layer.zPosition = focused ? 1 : 0
        cell.layer.shadowOffset = focused ? CGSize(width: -10, height: 10) : CGSize.zero
        cell.layer.shadowRadius = focused ? 5 : 0
        cell.layer.shadowOpacity = focused ? 0.1 : 0

        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil
        let finalColor = validationColor ?? cell.separatorColor
        cell.separatorView.backgroundColor = finalColor
    }
    
    public init() {}
}
