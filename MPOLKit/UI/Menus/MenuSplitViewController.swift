//
//  MenuSplitViewController.swift
//  Test
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// The `MenuSplitViewController` represents a standard split view controller
/// with a standard MPOL menu configuration.
///
/// You can either initialize with detail view controllers, and configure the menu directly
/// as required, or subclass as a point of abstraction between the menu and it's detail.
open class MenuSplitViewController: PushableSplitViewController {
    
    
    /// The menu controller for the split view controller.
    public let menuViewController: MenuViewController = MenuViewController(nibName: nil, bundle: nil)
    
    
    /// The detail controllers for the menu.
    public let detailViewControllers: [UIViewController]
    
    
    /// The selected view controller.
    ///
    /// If this is a navigation controller, it is presented directly.
    /// Otherwise, it is wrapped in a UINavigationController for presentation.
    public var selectedViewController: UIViewController? {
        didSet {
            menuViewController.selectedItem = selectedViewController?.menuItem
            if let selectedViewController = selectedViewController {
                let selectedVCNavItem = (selectedViewController as? UINavigationController)?.viewControllers.first?.navigationItem ?? selectedViewController.navigationItem
                selectedVCNavItem.leftItemsSupplementBackButton = true
                embeddedSplitViewController.showDetailViewController(navController(forDetail: selectedViewController), sender: self)
            }
        }
    }
    
    
    /// A boolean value indicating whether the split view controller should collapse
    /// to the menu.
    fileprivate var collapseToMenu: Bool = true
    
    
    /// Initializes the menu split view controller with the specified detail view controllers.
    ///
    /// - Parameter detailViewControllers: The detail view controllers. The menu items for these
    ///                                    items will appear in the menu.
    public init(detailViewControllers: [UIViewController]) {
        self.detailViewControllers = detailViewControllers
        selectedViewController = detailViewControllers.first { $0.menuItem.isEnabled }
        
        var viewControllers = [UINavigationController(rootViewController: menuViewController)]
        if let selectedViewController = self.selectedViewController {
            viewControllers.append(navController(forDetail: selectedViewController))
        }
        super.init(viewControllers: viewControllers)
        
        menuViewController.delegate = self
        menuViewController.items = detailViewControllers.map { $0.menuItem }
        
        let embeddedSplitViewController = self.embeddedSplitViewController
        embeddedSplitViewController.minimumPrimaryColumnWidth = 272.0
        embeddedSplitViewController.preferredPrimaryColumnWidthFraction = 272.0 / 1024.0
        
        var selectedItem: MenuItem?
        if embeddedSplitViewController.isCollapsed == false {
            selectedItem = selectedViewController?.menuItem
        }
        menuViewController.selectedItem = selectedItem
    }
    
    
    /// `MenuSplitViewController` does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("MenuSplitViewController does not support NSCoding.")
    }
    
    
    /// A callback indicating the collapsed state of the split changed.
    open func collapsedStateDidChange() {}
}


// MARK: - MenuViewControllerDelegate methods
/// MenuViewControllerDelegate methods
extension MenuSplitViewController : MenuViewControllerDelegate {
    
    ///
    /// - Parameters:
    ///   - controller: The `MenuViewController` that has a new selection.
    ///   - item:       The newly selected item.
    open func menuViewController(_ controller: MenuViewController, didSelectItem item: MenuItem) {
    }

    
    /// Handles when the menu selects a new source. By default, this does noting.
    ///
    /// - Parameters:
    ///   - controller: The `MenuViewController` where the item changed.
    ///   - index:      The menu source index selected.
    open func menuViewController(_ controller: MenuViewController, didSelectSourceAt index: Int) {
    }
    
}


// MARK: - UISplitViewControllerDelegate methods
/// UISplitViewControllerDelegate methods
extension MenuSplitViewController {
    
    open func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        collapseToMenu = false
        return false
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        menuViewController.selectedItem = nil
        menuViewController.clearsSelectionOnViewWillAppear = true
        perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])
        return collapseToMenu
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        menuViewController.selectedItem = selectedViewController?.menuItem
        menuViewController.clearsSelectionOnViewWillAppear = false
        perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])
        return nil
    }
    
}



fileprivate var MenuAssociatedObjectHandle: UInt8 = 0

/// Menu Item - UIViewController support
extension UIViewController {
    
    /// The menu item for the view controller. Automatically created lazily upon request.
    open var menuItem: MenuItem {
        if let menuItem = objc_getAssociatedObject(self, &MenuAssociatedObjectHandle) as? MenuItem {
            return menuItem
        }
        
        let newItem = MenuItem()
        newItem.title = title
        newItem.image = tabBarItem?.image
        objc_setAssociatedObject(self, &MenuAssociatedObjectHandle, newItem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newItem
    }
    
}

/// Convenience method to get the navigation controller for the detail, or create one if necessary.
fileprivate func navController(forDetail detail: UIViewController) -> UINavigationController {
    return detail as? UINavigationController ?? detail.navigationController ?? UINavigationController(rootViewController: detail)
}

