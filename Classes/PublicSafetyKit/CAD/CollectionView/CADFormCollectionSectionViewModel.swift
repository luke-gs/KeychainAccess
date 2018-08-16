//
//  CADFormCollectionSectionViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for handling the sections of a form collection view
open class CADFormCollectionSectionViewModel<ItemType> {

    /// Title for section header
    public let title: String?

    /// The section items
    public let items: [ItemType]

    /// Whether section should not be collapsed, even if expand arrow enabled in view model
    public let preventCollapse: Bool?

    public init(title: String?, items: [ItemType], preventCollapse: Bool? = false) {
        self.title = title
        self.items = items
        self.preventCollapse = preventCollapse
    }
}
