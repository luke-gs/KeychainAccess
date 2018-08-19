//
//  SidebarDelegate.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A sidebar view controller's delegate protocol
///
/// Implement this protocol when you want to observe selection actions within a sidebar.
public protocol SidebarDelegate : class {

    /// Indicates the sidebar has selected a new SidebarItem.
    func sidebarViewController(_ controller: UIViewController?, didSelectItem item: SidebarItem)

    /// Indicates the sidebar has selected a new Source.
    func sidebarViewController(_ controller: UIViewController, didSelectSourceAt index: Int)

    func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int)
}
