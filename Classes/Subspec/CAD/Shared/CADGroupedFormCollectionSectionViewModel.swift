//
//  CADGroupedFormCollectionSectionViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for handling the sections of a form collection view which also displays an additional header cell for the group name
open class CADGroupedFormCollectionSectionViewModel<ItemType, HeaderType> {
    
    /// Title for section header
    let title: String
    
    /// View model for the group header cell
    let header: HeaderType
    
    /// The section items
    let items: [ItemType]
    
    public init(title: String, header: HeaderType, items: [ItemType]) {
        self.title = title
        self.header = header
        self.items = items
    }
}
