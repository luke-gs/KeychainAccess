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
open class SidebarSplitViewController: PushableSplitViewController, SidebarViewControllerDelegate {
    
    /// The sidebar view controller when displayed horizontally in compact mode
    public var horizontalSidebarViewController: HorizontalSidebarViewController = HorizontalSidebarViewController()

    /// The sidebar view controller for the split view controller.
    public let sidebarViewController: SidebarViewController = SidebarViewController()
    
    public let masterNavController: NavigationControllerWithHeader
    public let detailNavController: UINavigationController

    /// The title to use for main navigation controller when in regular size
    open var regularTitle: String? {
        return title
    }

    /// The title to use for main navigation controller when in compact size
    open var compactTitle: String? {
        return title
    }

    /// The detail controllers for the sidebar.
    public var detailViewControllers: [UIViewController] {
        didSet {
            sidebarViewController.items = detailViewControllers.map { $0.sidebarItem }
            
            if let oldSelected = selectedViewController, detailViewControllers.contains(oldSelected) == false {
                selectedViewController = nil
            }
        }
    }
    
    
    /// The selected view controller.
    public var selectedViewController: UIViewController? {
        didSet {
            if let newValue = selectedViewController {
                precondition(detailViewControllers.contains(newValue), "`selectedViewController` must be a member of detailViewControllers.")
            }
            sidebarViewController.selectedItem = selectedViewController?.sidebarItem
            horizontalSidebarViewController.selectedItem = sidebarViewController.selectedItem
            if let selectedViewController = selectedViewController {
                if self.isCompact() {
                    masterNavController.viewControllers = [selectedViewController]
                } else {
                    detailNavController.viewControllers = [selectedViewController]
                    embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
                }
            } else if let defaultViewController = detailViewControllers.first {
                // No selection, use first detail if compact (can't show nothing)
                if self.isCompact() {
                    masterNavController.viewControllers = [defaultViewController]
                } else {
                    detailNavController.viewControllers = []
                    embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
                }
            }
            updateNavigationBarForSelection()
        }
    }
    

    /// Is the split view controller being rendered in compact environment, hence collapsed
    public func isCompact() -> Bool {
        return self.traitCollection.horizontalSizeClass == .compact
    }


    /// Initializes the sidebar split view controller with the specified detail view controllers.
    ///
    /// - Parameter detailViewControllers: The detail view controllers. The sidebar items for these
    ///                                    items will appear in the sidebar.
    public init(detailViewControllers: [UIViewController]) {
        self.detailViewControllers = detailViewControllers
        selectedViewController = detailViewControllers.first { $0.sidebarItem.isEnabled }

        masterNavController = NavigationControllerWithHeader(rootViewController: sidebarViewController)
        detailNavController = UINavigationController()

        if let selectedViewController = self.selectedViewController {
            detailNavController.viewControllers = [selectedViewController]

            // Check the screen trait collection, as self is not initialised yet
            if UIScreen.main.traitCollection.horizontalSizeClass == .compact {
                // Force early detail vc collapse so animation looks good
                masterNavController.viewControllers = [selectedViewController]
                detailNavController.viewControllers = []
            }
        }
        
        super.init(viewControllers: [masterNavController, detailNavController])

        // Create header sidebar for horizontal navigation, visible only when compact
        self.addChildViewController(horizontalSidebarViewController)
        horizontalSidebarViewController.didMove(toParentViewController: self)
        masterNavController.headerView = horizontalSidebarViewController.view
        sidebarViewController.edgesForExtendedLayout = []

        sidebarViewController.delegate = self
        sidebarViewController.items = detailViewControllers.map { $0.sidebarItem }

        horizontalSidebarViewController.delegate = self
        horizontalSidebarViewController.items = detailViewControllers.map { $0.sidebarItem }
        
        let embeddedSplitViewController = self.embeddedSplitViewController
        embeddedSplitViewController.delegate = self
        embeddedSplitViewController.minimumPrimaryColumnWidth = 288.0
        embeddedSplitViewController.preferredPrimaryColumnWidthFraction = 320.0 / 1024.0
        embeddedSplitViewController.delegate = self

        var selectedItem: SidebarItem?
        if embeddedSplitViewController.isCollapsed == false {
            selectedItem = selectedViewController?.sidebarItem
        }
        sidebarViewController.selectedItem = selectedItem
        horizontalSidebarViewController.selectedItem = selectedItem
    }

    /// `SidebarSplitViewController` does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarForTraits()
    }

    /// A callback indicating the collapsed state of the split changed.
    open func collapsedStateDidChange() {}
    
    // MARK: - iPhone support

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            // Update header bar and split view controller for new trait
            self?.updateSplitViewControllerForTraits()
            self?.updateNavigationBarForTraits()
            }, completion: nil)
    }

    func updateSplitViewControllerForTraits() {
        if self.isCompact() {
            // Split displayed as single view, with details collapsed on top of master
            // Update the master nav view controller to actually contain the detail, to remove the sidebar
            if masterNavController.viewControllers.contains(sidebarViewController) {
                if let detailViewController = self.selectedViewController ?? self.detailViewControllers.first {
                    masterNavController.viewControllers = [detailViewController]
                }
            }
        } else {
            // Split displayed as both views visible at same time
            // Restore the master nav view controller if collapsing has removed the sidebar from it
            if !masterNavController.viewControllers.contains(sidebarViewController) {
                masterNavController.viewControllers = [sidebarViewController]
            }
        }
    }

    func updateNavigationBarForSelection() {
        // Make sure the current master view controller has the back button
        // Note: this can move to detail view controller when switching between regular and compact
        masterNavController.viewControllers.first?.navigationItem.leftBarButtonItems = nil
        masterNavController.viewControllers.first?.navigationItem.leftBarButtonItem = backButtonItem()
        detailNavController.viewControllers.first?.navigationItem.leftBarButtonItem = nil

        // Update the navigation bar titles
        masterNavController.viewControllers.first?.navigationItem.title = self.isCompact() ? compactTitle : regularTitle
        detailNavController.viewControllers.first?.navigationItem.title = detailNavController.viewControllers.first?.title
    }

    func updateNavigationBarForTraits() {
        updateNavigationBarForSelection()

        // Workaround for nav bar issue where title and back button are not updated when switching from compact to regular
        if !self.isCompact() {
            if let selectedViewController = selectedViewController {
                detailNavController.viewControllers = []
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
                detailNavController.viewControllers = [selectedViewController]
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
            }
        }
    }

    // MARK: - SidebarViewControllerDelegate methods
    
    /// Handles when the sidebar selects a new item.
    /// By default, this selects the associated detail view controller.
    ///
    /// - Parameters:
    ///   - controller: The `SidebarViewController` that has a new selection.
    ///   - item:       The newly selected item.
    open func sidebarViewController(_ controller: SidebarViewController?, didSelectItem item: SidebarItem) {
        selectedViewController = detailViewControllers.first(where: { $0.sidebarItem == item })
    }

    /// Handles when the sidebar selects a new source. By default, this does noting.
    ///
    /// - Parameters:
    ///   - controller: The `SidebarViewController` where the item changed.
    ///   - index:      The sidebar source index selected.
    open func sidebarViewController(_ controller: SidebarViewController, didSelectSourceAt index: Int) {
    }
    
    open func sidebarViewController(_ controller: SidebarViewController, didRequestToLoadSourceAt index: Int) {
        
    }
    
    
    // MARK: - UISplitViewControllerDelegate methods

    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        sidebarViewController.selectedItem = nil
        sidebarViewController.clearsSelectionOnViewWillAppear = true
        perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])

        return isCompact()
    }

    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        sidebarViewController.selectedItem = selectedViewController?.sidebarItem
        sidebarViewController.clearsSelectionOnViewWillAppear = false
        perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])

        // Restore the detail nav view controller for split screen
        if let detailViewController = self.selectedViewController ?? self.detailViewControllers.first {
            detailNavController.viewControllers = [detailViewController]
            return detailNavController
        }
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

