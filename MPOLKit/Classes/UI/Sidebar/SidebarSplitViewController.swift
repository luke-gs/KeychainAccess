//
//  SidebarSplitViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// The `SidebarSplitViewController` represents a standard split view controller
/// with a standard MPOL sidebar configuration.
///
/// You can either initialize with detail view controllers, and configure the sidebar directly
/// as required, or subclass as a point of abstraction between the sidebar and it's detail.
open class SidebarSplitViewController: PushableSplitViewController {
    
    
    /// The sidebar view controller for the split view controller.
    public let sidebarViewController: SidebarViewController = SidebarViewController(nibName: nil, bundle: nil)
    
    
    /// The detail controllers for the sidebar.
    public let detailViewControllers: [UIViewController]
    
    
    /// The selected view controller.
    ///
    /// If this is a navigation controller, it is presented directly.
    /// Otherwise, it is wrapped in a UINavigationController for presentation.
    public var selectedViewController: UIViewController? {
        didSet {
            sidebarViewController.selectedItem = selectedViewController?.sidebarItem
            if let selectedViewController = selectedViewController {
                let selectedVCNavItem = (selectedViewController as? UINavigationController)?.viewControllers.first?.navigationItem ?? selectedViewController.navigationItem
                selectedVCNavItem.leftItemsSupplementBackButton = true
                embeddedSplitViewController.showDetailViewController(navController(forDetail: selectedViewController), sender: self)
            }
        }
    }
    
    
    /// A boolean value indicating whether the split view controller should collapse
    /// to the sidebar.
    fileprivate var collapseToSidebar: Bool = true
    
    
    /// Initializes the sidebar split view controller with the specified detail view controllers.
    ///
    /// - Parameter detailViewControllers: The detail view controllers. The sidebar items for these
    ///                                    items will appear in the sidebar.
    public init(detailViewControllers: [UIViewController]) {
        self.detailViewControllers = detailViewControllers
        selectedViewController = detailViewControllers.first { $0.sidebarItem.isEnabled }
        
        var viewControllers = [UINavigationController(rootViewController: sidebarViewController)]
        if let selectedViewController = self.selectedViewController {
            viewControllers.append(navController(forDetail: selectedViewController))
        }
        super.init(viewControllers: viewControllers)
        
        sidebarViewController.delegate = self
        sidebarViewController.items = detailViewControllers.map { $0.sidebarItem }
        
        let embeddedSplitViewController = self.embeddedSplitViewController
        embeddedSplitViewController.minimumPrimaryColumnWidth = 272.0
        embeddedSplitViewController.preferredPrimaryColumnWidthFraction = 272.0 / 1024.0
        
        var selectedItem: SidebarItem?
        if embeddedSplitViewController.isCollapsed == false {
            selectedItem = selectedViewController?.sidebarItem
        }
        sidebarViewController.selectedItem = selectedItem
    }
    
    
    /// `SidebarSplitViewController` does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("SidebarSplitViewController does not support NSCoding.")
    }
    
    
    /// A callback indicating the collapsed state of the split changed.
    open func collapsedStateDidChange() {}
}


// MARK: - SidebarViewControllerDelegate methods
/// SidebarViewControllerDelegate methods
extension SidebarSplitViewController : SidebarViewControllerDelegate {
    
    ///
    /// - Parameters:
    ///   - controller: The `SidebarViewController` that has a new selection.
    ///   - item:       The newly selected item.
    open func sidebarViewController(_ controller: SidebarViewController, didSelectItem item: SidebarItem) {
        selectedViewController = detailViewControllers.first(where: { $0.sidebarItem == item })
    }

    
    /// Handles when the sidebar selects a new source. By default, this does noting.
    ///
    /// - Parameters:
    ///   - controller: The `SidebarViewController` where the item changed.
    ///   - index:      The sidebar source index selected.
    open func sidebarViewController(_ controller: SidebarViewController, didSelectSourceAt index: Int) {
    }
    
}


// MARK: - UISplitViewControllerDelegate methods
/// UISplitViewControllerDelegate methods
extension SidebarSplitViewController {
    
    open func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        collapseToSidebar = false
        return false
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        sidebarViewController.selectedItem = nil
        sidebarViewController.clearsSelectionOnViewWillAppear = true
        perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])
        return collapseToSidebar
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        sidebarViewController.selectedItem = selectedViewController?.sidebarItem
        sidebarViewController.clearsSelectionOnViewWillAppear = false
        perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])
        return nil
    }
    
}



fileprivate var SidebarAssociatedObjectHandle: UInt8 = 0

/// Sidebar Item - UIViewController support
extension UIViewController {
    
    /// The sidebar item for the view controller. Automatically created lazily upon request.
    open var sidebarItem: SidebarItem {
        if let sidebarItem = objc_getAssociatedObject(self, &SidebarAssociatedObjectHandle) as? SidebarItem {
            return sidebarItem
        }
        
        let newItem = SidebarItem()
        newItem.title = title
        newItem.image = tabBarItem?.image
        objc_setAssociatedObject(self, &SidebarAssociatedObjectHandle, newItem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newItem
    }
    
}

/// Convenience method to get the navigation controller for the detail, or create one if necessary.
fileprivate func navController(forDetail detail: UIViewController) -> UINavigationController {
    return detail as? UINavigationController ?? detail.navigationController ?? UINavigationController(rootViewController: detail)
}

