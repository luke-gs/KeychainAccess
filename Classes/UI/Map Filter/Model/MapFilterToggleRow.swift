//
//  MapFilterToggleRow.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A representation of a row of toggles with a title
open class MapFilterToggleRow {

    /// The title for the section
    open var title: String?
    
    /// The options to show
    open var options: [MapFilterOption]
    
    /// - Parameters:
    ///   - title: the title for the section
    ///   - options: the options to show
    public init(title: String? = nil, options: [MapFilterOption]) {
        self.title = title
        self.options = options
    }
}
