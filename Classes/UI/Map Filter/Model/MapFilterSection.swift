//
//  MapFilterSection.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A section to show in the map filter
open class MapFilterSection {
    
    /// Title for the section
    open var title: String
    
    /// Whether the filter for the section is on. `nil` if option is not shown
    open var isOn: Bool?
    
    /// Rows of toggle options
    open var toggleRows: [MapFilterToggleRow]
    
    /// - Parameters:
    ///   - title: the title for the section
    ///   - isOn: whether the filter for the section is enabled. Set to `nil` to not show an option
    ///   - toggleRows: the rows of toggle options
    public init(title: String, isOn: Bool?, toggleRows: [MapFilterToggleRow] = []) {
        self.title = title
        self.isOn = isOn
        self.toggleRows = toggleRows
    }
}
