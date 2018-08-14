//
//  TableViewStyle.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class TableViewStyle: CellSelectionAnimatable {
    public static func configure(_ cell: CollectionViewFormCell, isFocused focused: Bool) {

        if ThemeManager.shared.currentInterfaceStyle.isDark {
            cell.backgroundColor = focused ? .sidebarGray : .clear
        } else {
            cell.backgroundColor = focused ? .selectedGray : .clear
        }

        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil
        let finalColor = validationColor ?? cell.separatorColor
        cell.separatorView.backgroundColor = finalColor
    }

    public init() {}
}
