//
//  MapFilterSection.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A section to show in the map filter
open class MapFilterSection: NSObject {
    
    /// Title for the section
    open var title: String
    
    /// Whether the filter for the section is enabled. `nil` if option is not shown
    open var isEnabled: Bool?
    
    /// Rows of toggle options
    open var toggleRows: [MapFilterToggleRow]
    
    
    /// - Parameters:
    ///   - title: the title for the section
    ///   - isEnabled: whether the filter for the section is enabled. Set to `nil` to not show an option
    ///   - toggleRows: the rows of toggle options
    public init(title: String, isEnabled: Bool?, toggleRows: [MapFilterToggleRow] = []) {
        self.title = title
        self.isEnabled = isEnabled
        self.toggleRows = toggleRows
    }
}
