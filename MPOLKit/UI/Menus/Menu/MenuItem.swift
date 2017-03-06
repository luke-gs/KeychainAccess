//
//  MenuItem.swift
//  Test
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// The `MenuItem` class implements an item on a `MenuViewController` object.
///
/// A menu operates strictly in radio mode, where one item is selected at a time —
/// tapping a menu button toggles the view selected. You can also specify a count
/// value indicating a count value on the trailing edge of the menu button.
open class MenuItem: NSObject {
    
    /// Indicates whether the item is enabled. The default is `true`.
    open dynamic var isEnabled: Bool = true
    
    /// The image to display representing the item.
    ///
    /// Using a template image applies the `MenuItem.color` property as a tint.
    open dynamic var image: UIImage?
    
    /// The image to display representing the item when selected.
    ///
    /// Using a template image applies the `MenuItem.selectedColor` property as a tint.
    open dynamic var selectedImage: UIImage?
    
    /// The localized title of the item.
    open dynamic var title: String?
    
    /// A count indicating an additional numerical number for the item.
    open dynamic var count: UInt = 0
    
    /// The color to tint the image.
    @NSCopying open dynamic var color: UIColor?
    
    /// The color to tint the image (or selected image) when selected.
    @NSCopying open dynamic var selectedColor: UIColor?
    
    /// The color to apply to the badge icon over the image.
    ///
    /// When nil, the badge is not displayed. The default is `nil`.
    @NSCopying open dynamic var badgeColor:    UIColor?
}
