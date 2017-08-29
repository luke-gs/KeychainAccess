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
    
    public var headerNavigationView: UIView?

    /// The sidebar view controller for the split view controller.
    public let sidebarViewController: SidebarViewController = SidebarViewController()
    
    public let masterNavController: UINavigationController
    public let detailNavController: UINavigationController

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
    ///
    /// If this is a navigation controller, it is presented directly.
    /// Otherwise, it is wrapped in a UINavigationController for presentation.
    public var selectedViewController: UIViewController? {
        didSet {
            if let newValue = selectedViewController {
                precondition(detailViewControllers.contains(newValue), "`selectedViewController` must be a member of detailViewControllers.")
            }
            
            sidebarViewController.selectedItem = selectedViewController?.sidebarItem
            if let selectedViewController = selectedViewController {
                let selectedVCNavItem = (selectedViewController as? UINavigationController)?.viewControllers.first?.navigationItem ?? selectedViewController.navigationItem
                selectedVCNavItem.leftItemsSupplementBackButton = true
                embeddedSplitViewController.showDetailViewController(navController(forDetail: selectedViewController), sender: self)
            } else {
                var splitViewControllers = embeddedSplitViewController.viewControllers
                if splitViewControllers.count == 2 {
                    splitViewControllers.remove(at: 1)
                    embeddedSplitViewController.viewControllers = splitViewControllers
                }
            }
        }
    }
    
    
    /// A boolean value indicating whether the split view controller should collapse
    /// to the sidebar.
    open var shouldCollapseToSidebar: Bool = true
    
    
    /// Initializes the sidebar split view controller with the specified detail view controllers.
    ///
    /// - Parameter detailViewControllers: The detail view controllers. The sidebar items for these
    ///                                    items will appear in the sidebar.
    public init(detailViewControllers: [UIViewController]) {
        self.detailViewControllers = detailViewControllers
        selectedViewController = detailViewControllers.first { $0.sidebarItem.isEnabled }

        masterNavController = UINavigationController(rootViewController: sidebarViewController)
        detailNavController = UINavigationController()

        if let selectedViewController = self.selectedViewController {
            detailNavController.viewControllers = [selectedViewController]

            if true { //self.traitCollection.horizontalSizeClass == .compact {
                // Force early detail vc collapse so animation looks good
                masterNavController.viewControllers = [selectedViewController]
                detailNavController.viewControllers = []
            }
        }
        
        super.init(viewControllers: [masterNavController, detailNavController])

        sidebarViewController.delegate = self
        sidebarViewController.items = detailViewControllers.map { $0.sidebarItem }
        
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
    }

    /// `SidebarSplitViewController` does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateHeaderNavigation()
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            self?.updateHeaderNavigation()
            self?.updateSplitViewControllerForTraits()
            }, completion: nil)
    }

    func updateSplitViewControllerForTraits() {
        if self.traitCollection.horizontalSizeClass == .compact {
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

    func updateHeaderNavigation() {
        if self.traitCollection.horizontalSizeClass == .compact {
            if #available(iOS 11.0, *) {
                masterNavController.additionalSafeAreaInsets = UIEdgeInsetsMake(50, 0, 0, 0)
            } else {
                // TODO
            }
            headerNavigationView = createHeaderNavigationBar()
        } else {
            if #available(iOS 11.0, *) {
                masterNavController.additionalSafeAreaInsets = .zero
            } else {
                // TODO
            }
            headerNavigationView?.removeFromSuperview()
            headerNavigationView = nil
        }
    }

    func createHeaderNavigationBar() -> UIView {
        let topY = masterNavController.navigationBar.frame.maxY
        let view = UIView(frame: CGRect(x: 0, y: topY, width: masterNavController.view.bounds.width, height: 50))
        view.backgroundColor = UIColor.green
        view.translatesAutoresizingMaskIntoConstraints = false
        masterNavController.view.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: masterNavController.navigationBar.bottomAnchor),
            view.leftAnchor.constraint(equalTo: masterNavController.navigationBar.leftAnchor),
            view.rightAnchor.constraint(equalTo: masterNavController.navigationBar.rightAnchor),
            view.heightAnchor.constraint(equalToConstant: 50)
            ])
        return view
    }

    /// A callback indicating the collapsed state of the split changed.
    open func collapsedStateDidChange() {}
    
    
    // MARK: - SidebarViewControllerDelegate methods
    
    /// Handles when the sidebar selects a new item.
    /// By default, this selects the associated detail view controller.
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
    
    open func sidebarViewController(_ controller: SidebarViewController, didRequestToLoadSourceAt index: Int) {
        
    }
    
    
    // MARK: - UISplitViewControllerDelegate methods

    open func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        // TODO: method renamed? point of this anyway?
        shouldCollapseToSidebar = false
        return false
    }

    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        sidebarViewController.selectedItem = nil
        sidebarViewController.clearsSelectionOnViewWillAppear = true
        perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])
        let shouldCollapse = (self.traitCollection.horizontalSizeClass == .compact)
        return shouldCollapse
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

