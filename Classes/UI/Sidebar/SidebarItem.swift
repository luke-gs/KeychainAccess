//
//  SidebarItem.swift
//  MPOLKit
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
@objcMembers
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
    
    /// The localized title of the item in regular size class.
    ///
    /// Differs from `compactTitle` as regular should always be plural
    /// because of the way it's displayed. i.e. Actions (4), Associations (1)
    open dynamic var regularTitle: String?
    
    /// The localized title of the item in compact size class.
    ///
    /// Differs from `regularTitle` as compact may be singular or plural
    /// because of the way it's displayed. i.e. 4 Actions, 1 Association
    open dynamic var compactTitle: String?
    
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


// MARK: - UIViewController extension

/// Global var for unique address as the assoc object handle
fileprivate var SidebarAssociatedObjectHandle: UInt8 = 0

extension UIViewController {

    /// The sidebar item for the view controller. Automatically created lazily upon request.
    open var sidebarItem: SidebarItem {
        if let sidebarItem = objc_getAssociatedObject(self, &SidebarAssociatedObjectHandle) as? SidebarItem {
            return sidebarItem
        }

        let newItem = SidebarItem()
        newItem.compactTitle = title
        newItem.regularTitle = title
        newItem.image = tabBarItem?.image
        objc_setAssociatedObject(self, &SidebarAssociatedObjectHandle, newItem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newItem
    }
}
