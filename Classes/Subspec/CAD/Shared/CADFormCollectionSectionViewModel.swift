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
    let title: String

    /// The section items
    let items: [ItemType]

    public init(title: String, items: [ItemType]) {
        self.title = title
        self.items = items
    }
}
