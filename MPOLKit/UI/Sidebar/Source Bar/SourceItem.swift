//
//  SourceItem.swift
//  Test
//
//  Created by Rod Brown on 13/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// An item representing a source in a source list.
public struct SourceItem {
    
    /// The color for the item. This color is applied to the round icon, and the
    /// count when not selected.
    var color: UIColor
    
    /// The title to show under the item.
    var title: String
    
    /// The count for the item. This nubmer will appear within the selection icon.
    var count: UInt
    
    /// Indicates whether the item is enabled. The default is `true`.
    var isEnabled: Bool
    
    /// Initializes a SourceItem.
    public init(color: UIColor, title: String, count: UInt, isEnabled: Bool = true) {
        self.color = color
        self.title = title
        self.count = count
        self.isEnabled = isEnabled
    }
}
