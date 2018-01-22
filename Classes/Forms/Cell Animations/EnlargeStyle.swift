//
//  File.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class EnlargeStyle: CellSelectionAnimatable {
    public static func configure(_ cell: CollectionViewFormCell, forState state: Bool) {

        let transform = state ? CGAffineTransform(scaleX: 1.05, y: 1.05) : CGAffineTransform.identity
        cell.transform = transform
        cell.layer.zPosition = state ? 1 : 0
        cell.layer.shadowOffset = state ? CGSize(width: -10, height: 10) : CGSize.zero
        cell.layer.shadowRadius = state ? 5 : 0
        cell.layer.shadowOpacity = state ? 0.1 : 0

        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil
        let finalColor = validationColor ?? cell.separatorColor
        cell.separatorView.backgroundColor = finalColor
    }
    
    public init() {}
}
