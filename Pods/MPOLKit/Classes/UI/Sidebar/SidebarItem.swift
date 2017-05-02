//
//  SidebarItem.swift
//  Test
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// The `SidebarItem` class implements an item on a `SidebarViewController` object.
///
/// A sidebar operates strictly in radio mode, where one item is selected at a time —
/// tapping a sidebar button toggles the view selected. You can also specify a count
/// value indicating a count value on the trailing edge of the sidebar button.
open class SidebarItem: NSObject {
    
    /// Indicates whether the item is enabled. The default is `true`.
    open dynamic var isEnabled: Bool = true
    
    /// The image to display representing the item.
    ///
    /// Using a template image applies the `SidebarItem.color` property as a tint.
    open dynamic var image: UIImage?
    
    /// The image to display representing the item when selected.
    ///
    /// Using a template image applies the `SidebarItem.selectedColor` property as a tint.
    open dynamic var selectedImage: UIImage?
    
    /// The localized title of the item.
    open dynamic var title: String?
    
    /// A count indicating an additional numerical number for the item.
    open dynamic var count: UInt = 0
    
    /// The color to tint the image.
    @NSCopying open dynamic var color: UIColor?
    
    /// The color to tint the image (or selected image) when selected.
    @NSCopying open dynamic var selectedColor: UIColor?
    
    /// The color to apply to the alert icon over the image.
    ///
    /// When nil, the icon is not displayed. The default is `nil`.
    @NSCopying open dynamic var alertColor: UIColor?
}
