//
//  Collection+MapFilterSectionCopy.swift
//  MPOLKit
//
//  Created by Kyle May on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension Collection where Iterator.Element: MapFilterSection {
    
    /// Makes a deep copy of an array of map filter sections
    public func copy() -> [MapFilterSection] {
        return self.map { section in
            let toggleRows: [MapFilterToggleRow] = section.toggleRows.map { toggleRow in
                let options: [MapFilterOption] = toggleRow.options.map { option in
                    return MapFilterOption(text: option.text, isEnabled: option.isEnabled, isOn: option.isOn)
                }
                return MapFilterToggleRow(title: toggleRow.title, options: options)
            }
            return MapFilterSection(title: section.title, isOn: section.isOn, toggleRows: toggleRows)
        }
    }
}

