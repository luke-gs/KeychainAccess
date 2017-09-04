//
//  SidebarSplitViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The `SidebarSplitViewController` represents a standard split view controller
/// with a standard MPOL sidebar configuration in regular mode, and a horizontal menu when in compact.
///
/// You can either initialize with detail view controllers, and configure the sidebar directly
/// as required, or subclass as a point of abstraction between the sidebar and it's detail.
open class SidebarSplitViewController: PushableSplitViewController {
    
    /// The sidebar view controller when displayed horizontally in compact mode
    public var horizontalSidebarViewController: HorizontalSidebarViewController = HorizontalSidebarViewController()

    /// The sidebar view controller for the split view controller.
    public let sidebarViewController: SidebarViewController = SidebarViewController()

    // The navigation controller for the master side of split view
    public let masterNavController: NavigationControllerWithHeader

    // The navigation controller for the detail side of split view
    public let detailNavController: UINavigationController

    // The page view controller for handling compact mode paging behaviour
    public let pageViewController: ScrollAwarePageViewController

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
            if selectedViewController != oldValue {
                updateSplitViewControllerForSelection()
            }
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

        // Set up the page controller
        pageViewController = ScrollAwarePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        masterNavController = NavigationControllerWithHeader(rootViewController: sidebarViewController)
        detailNavController = UINavigationController()

        if let selectedViewController = self.selectedViewController {
            detailNavController.viewControllers = [selectedViewController]

            // Check the root view controller trait collection, as self is not initialised yet
            if let traitCollection = UIApplication.shared.keyWindow?.rootViewController?.traitCollection, traitCollection.horizontalSizeClass == .compact {
                // Force early detail vc collapse so presentation animation looks good
                pageViewController.setViewControllers([selectedViewController], direction: .forward, animated: false, completion: nil)
                masterNavController.viewControllers = [pageViewController]
                detailNavController.viewControllers = []
            }
        }

        super.init(viewControllers: [masterNavController, detailNavController])

        pageViewController.scrollDelegate = self
        pageViewController.dataSource = self
        pageViewController.delegate = self

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
    
    // MARK: - Private methods

    private func updateSplitViewControllerForSelection() {
        // Update the highlighted menu item
        sidebarViewController.selectedItem = selectedViewController?.sidebarItem
        horizontalSidebarViewController.selectedItem = sidebarViewController.selectedItem

        // Update the visible view controller
        if let selectedViewController = selectedViewController {
            if self.isCompact() {
                pageViewController.setViewControllers([selectedViewController], direction: .forward, animated: false, completion: nil)
                masterNavController.viewControllers = [pageViewController]
            } else {
                detailNavController.viewControllers = [selectedViewController]
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
            }
        } else if let defaultViewController = detailViewControllers.first {
            // No selection, use first detail if compact (can't show nothing)
            if self.isCompact() {
                pageViewController.setViewControllers([defaultViewController], direction: .forward, animated: false, completion: nil)
                masterNavController.viewControllers = [pageViewController]
            } else {
                detailNavController.viewControllers = []
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
            }
        }
        updateNavigationBarForSelection()
    }

    // MARK: - iPhone support

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            // Update header bar and split view controller for new trait
            self?.updateSplitViewControllerForTraits()
            self?.updateNavigationBarForTraits()
            }, completion: nil)
    }

    private func updateSplitViewControllerForTraits() {
        if self.isCompact() {
            // Split displayed as single view, with details collapsed on top of master
            // Update the master nav view controller to actually contain the detail, to remove the sidebar
            if masterNavController.viewControllers.contains(sidebarViewController) {
                if let detailViewController = self.selectedViewController ?? self.detailViewControllers.first {
                    pageViewController.setViewControllers([detailViewController], direction: .forward, animated: false, completion: nil)
                    detailNavController.viewControllers = []
                    masterNavController.viewControllers = [pageViewController]
                }
            }
        } else {
            // Split displayed as both views visible at same time
            // Restore the master nav view controller if collapsing has removed the sidebar from it
            if !masterNavController.viewControllers.contains(sidebarViewController) {
                pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
                masterNavController.viewControllers = [sidebarViewController]
            }
        }
    }

    private func updateNavigationBarForSelection() {
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

}

// MARK: - SidebarViewControllerDelegate methods
extension SidebarSplitViewController: SidebarViewControllerDelegate {

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
}

// MARK: - UISplitViewControllerDelegate methods
extension SidebarSplitViewController {
    
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

// MARK: - UIPageViewControllerDataSource methods
extension SidebarSplitViewController: UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = detailViewControllers.index(of: viewController), index + 1 < detailViewControllers.count else {
            return nil
        }
        return detailViewControllers[index+1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = detailViewControllers.index(of: viewController), index > 0 else {
            return nil
        }
        return detailViewControllers[index-1]
    }
}

// MARK: - UIPageViewControllerDelegate methods
extension SidebarSplitViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first {
            // Dispath update to the selected view controller, so animation is complete
            DispatchQueue.main.async {
                if completed {
                    self.selectedViewController = currentVC
                }
            }
        }
    }
}

// MARK: - UIScrollViewDelegate methods
extension SidebarSplitViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isCompact() {
            // Update the horizontal scrollbar to match the page view
            let pointX = scrollView.contentOffset.x - view.frame.size.width
            let percentOffset = pointX / view.frame.size.width
            horizontalSidebarViewController.setScrollOffsetPercent(percentOffset)
        }
    }
}

