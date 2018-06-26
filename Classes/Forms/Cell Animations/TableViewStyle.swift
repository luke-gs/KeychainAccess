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
            cell.backgroundColor = focused ? #colorLiteral(red: 0.9150436521, green: 0.9147670865, blue: 0.9054462314, alpha: 1) : .clear
        }

        let validationColor: UIColor? = cell.requiresValidation ? cell.validationColor : nil
        let finalColor = validationColor ?? cell.separatorColor
        cell.separatorView.backgroundColor = finalColor
    }

    public init() {}
}
