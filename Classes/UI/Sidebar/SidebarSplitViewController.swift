//
//  SidebarSplitViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 10/2/17, edited by Trent Fitzgibbon.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// KVO context for navigation items
fileprivate var navItemsContext = 0

/// Keypath for rightBarButtonItems
fileprivate let keypathRightBarButtonItems = #keyPath(UINavigationItem.rightBarButtonItems)

/// The SidebarSplitViewController represents a standard split view controller that can be pushed on to
/// a UINavigationController stack and includes a sidebar of navigation menu items that can be displayed
/// in both regular and compact size environments.
///
/// The sidebar is a table master VC in regular mode, and a horizontal strip above a detail VC in compact mode
open class SidebarSplitViewController: PushableSplitViewController {
    
    /// The sidebar view controller when displayed horizontally in compact mode
    public var compactSidebarViewController = CompactSidebarViewController()

    /// The sidebar view controller for the split view controller.
    public let regularSidebarViewController = RegularSidebarViewController()

    // The navigation controller for the master side of split view
    public let masterNavController: NavigationControllerWithHeader

    // The navigation controller for the detail side of split view
    public let detailNavController: UINavigationController

    // The page view controller for handling compact mode paging behaviour
    public let pageViewController: ScrollAwarePageViewController

    /// The title to use for the master navigation controller for the given traits
    open func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        MPLRequiresConcreteImplementation()
    }

    /// The detail controllers for the sidebar.
    public var detailViewControllers: [UIViewController] {
        didSet {
            regularSidebarViewController.items = detailViewControllers.map { $0.sidebarItem }
            compactSidebarViewController.items = detailViewControllers.map { $0.sidebarItem }
            if let oldSelected = selectedViewController, detailViewControllers.contains(oldSelected) == false {
                selectedViewController = nil
            }
        }
    }

    /// The selected view controller.
    public var selectedViewController: UIViewController? {
        didSet {
            if selectedViewController != oldValue {

                // Observer changes to navigations items
                if let oldValue = oldValue {
                    oldValue.navigationItem.removeObserver(self, forKeyPath: keypathRightBarButtonItems, context: &navItemsContext)
                }
                if let newValue = selectedViewController {
                    precondition(detailViewControllers.contains(newValue), "`selectedViewController` must be a member of detailViewControllers.")
                    newValue.navigationItem.addObserver(self, forKeyPath: keypathRightBarButtonItems, context: &navItemsContext)
                }
                // Update the split view content
                updateSplitViewControllerForSelection()
            }
        }
    }

    /// Whether a user should be allowed to change the selected detail view controller
    public var allowDetailSelection: Bool = true {
        didSet {
            // Disable table selection if not available
            regularSidebarViewController.sidebarTableView?.allowsSelection = allowDetailSelection

            // Disable selection from compact sidebar, or scroll pagination if not available
            compactSidebarViewController.view.isUserInteractionEnabled = allowDetailSelection
            pageViewController.scrollView?.isScrollEnabled = allowDetailSelection
        }
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
        pageViewController.view.backgroundColor = UIColor.white

        masterNavController = NavigationControllerWithHeader(rootViewController: regularSidebarViewController)
        detailNavController = UINavigationController()

        if let selectedViewController = self.selectedViewController {
            // Check whether the window is compact, as we can't check self yet
            if SidebarSplitViewController.isWindowCompact() {
                // Force early compact collapse so presentation animation looks good
                pageViewController.setViewControllers([selectedViewController], direction: .forward, animated: false, completion: nil)
                masterNavController.viewControllers = [pageViewController]
                detailNavController.viewControllers = []
            } else {
                // Show selected VC in detail side of split
                detailNavController.viewControllers = [selectedViewController]
            }
        }

        super.init(viewControllers: [masterNavController, detailNavController])

        // Handle all page view delegates
        pageViewController.scrollDelegate = self
        pageViewController.dataSource = self
        pageViewController.delegate = self

        // Create header sidebar for horizontal navigation, visible only when compact
        self.addChildViewController(compactSidebarViewController)
        compactSidebarViewController.didMove(toParentViewController: self)
        masterNavController.headerView = compactSidebarViewController.view
        regularSidebarViewController.edgesForExtendedLayout = []

        // Initialise sidebar menu items
        regularSidebarViewController.delegate = self
        regularSidebarViewController.items = detailViewControllers.map { $0.sidebarItem }

        compactSidebarViewController.delegate = self
        compactSidebarViewController.items = detailViewControllers.map { $0.sidebarItem }

        // Configure split view
        let embeddedSplitViewController = self.embeddedSplitViewController
        embeddedSplitViewController.delegate = self
        embeddedSplitViewController.minimumPrimaryColumnWidth = 288.0
        embeddedSplitViewController.preferredPrimaryColumnWidthFraction = 320.0 / 1024.0
        embeddedSplitViewController.delegate = self

        let selectedItem = selectedViewController?.sidebarItem
        regularSidebarViewController.selectedItem = selectedItem
        compactSidebarViewController.selectedItem = selectedItem

        // Add kvo observer, as didSet not called in init
        selectedViewController?.navigationItem.addObserver(self, forKeyPath: keypathRightBarButtonItems, context: &navItemsContext)
    }

    /// `SidebarSplitViewController` does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        // Remove kvo observer
        selectedViewController?.navigationItem.removeObserver(self, forKeyPath: keypathRightBarButtonItems, context: &navItemsContext)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarForTraits()
    }

    /// Is the split view controller being rendered in compact environment, hence collapsed
    public func isCompact() -> Bool {
        return self.traitCollection.horizontalSizeClass == .compact
    }

    /// Is the key window being rendered in compact environment
    public static func isWindowCompact() -> Bool {
        if let traitCollection = UIApplication.shared.keyWindow?.rootViewController?.traitCollection,
            traitCollection.horizontalSizeClass == .compact {
            return true
        }
        return false
    }

    // MARK: - Private methods

    private func updateSplitViewControllerForSelection() {
        // Update the highlighted menu item
        let selectedItem = selectedViewController?.sidebarItem
        regularSidebarViewController.selectedItem = selectedItem
        UIView.performWithoutAnimation {
            self.compactSidebarViewController.selectedItem = selectedItem
        }

        // Update the visible view controller
        if let selectedViewController = selectedViewController {
            if self.isCompact() {
                if !selectedViewController.isViewLoaded {
                    // Fade in view if not previously loaded
                    selectedViewController.view.alpha = 0
                }
                let fadeDuration = pageViewScrollOffset() != 0 ? 0 : 0.2
                UIView.transition(with: pageViewController.view, duration: fadeDuration, options: .transitionCrossDissolve, animations: {
                    selectedViewController.view.alpha = 1
                    self.pageViewController.setViewControllers([selectedViewController], direction: .forward, animated: false, completion: nil)
                }, completion: nil)
            } else {
                detailNavController.viewControllers = [selectedViewController]
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
            }
        } else if let defaultViewController = detailViewControllers.first {
            // No selection, use first detail if compact (can't show nothing)
            if self.isCompact() {
                pageViewController.setViewControllers([defaultViewController], direction: .forward, animated: false, completion: nil)
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
        guard let detailViewController = self.selectedViewController ?? self.detailViewControllers.first else { return }
        if self.isCompact() {
            // Split displayed as single view, with details collapsed on top of master
            if !masterNavController.viewControllers.contains(pageViewController) {
                // Clear old state
                detailNavController.viewControllers = []

                // Use the paging view controller in the master nav controller
                pageViewController.setViewControllers([detailViewController], direction: .forward, animated: false, completion: nil)
                masterNavController.viewControllers = [pageViewController]
            }
        } else {
            // Split displayed as both views visible at same time
            if !masterNavController.viewControllers.contains(regularSidebarViewController) {
                // Clear old state
                pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)

                // Use the regular sidebar view controller in the master nav controller
                masterNavController.viewControllers = [regularSidebarViewController]
                detailNavController.viewControllers = [detailViewController]
            }
        }
    }

    private func updateNavigationBarForSelection() {
        let masterNavItem = masterNavController.viewControllers.first?.navigationItem
        let detailNavItem = detailNavController.viewControllers.first?.navigationItem

        // Make sure the current master view controller has the back button
        // Note: this can move to detail view controller when switching between regular and compact
        masterNavItem?.leftBarButtonItems = [backButtonItem()].removeNils()
        detailNavItem?.leftBarButtonItem = nil

        // Move the right bar items to the master VC if compact
        if self.isCompact() {
            masterNavItem?.rightBarButtonItems = selectedViewController?.navigationItem.rightBarButtonItems
        }

        // Update the navigation bar titles, otherwise they can be shown on wrong side after transition
        masterNavItem?.title = masterNavTitleSuitable(for: traitCollection)
        detailNavItem?.title = detailNavController.viewControllers.first?.title
    }

    func updateNavigationBarForTraits() {
        updateNavigationBarForSelection()

        // Workaround for Apple bug where title and back button are not updated when switching from compact to regular
        if !self.isCompact() {
            if let selectedViewController = selectedViewController {
                detailNavController.viewControllers = []
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
                detailNavController.viewControllers = [selectedViewController]
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
            }
        }
    }

    // MARK: - KVO

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &navItemsContext {
            updateNavigationBarForSelection()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - SidebarDelegate methods
extension SidebarSplitViewController: SidebarDelegate {

    open func sidebarViewController(_ controller: UIViewController?, didSelectItem item: SidebarItem) {
        selectedViewController = detailViewControllers.first(where: { $0.sidebarItem == item })
    }

    open func sidebarViewController(_ controller: UIViewController, didSelectSourceAt index: Int) {
    }
    
    open func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int) {
    }
}

// MARK: - UISplitViewControllerDelegate methods
extension SidebarSplitViewController {
    
    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

        // Clear selected item if showing sidebar as entire view (Rod code, not used currently)
        //
        // regularSidebarViewController.selectedItem = nil
        // regularSidebarViewController.clearsSelectionOnViewWillAppear = true
        // perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])

        return isCompact()
    }

    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {

        // Restore selected item if showing sidebar as master in split (Rod code, not used currently)
        //
        // regularSidebarViewController.selectedItem = selectedViewController?.sidebarItem
        // regularSidebarViewController.clearsSelectionOnViewWillAppear = false
        // perform(#selector(collapsedStateDidChange), with: nil, afterDelay: 0.0, inModes: [.commonModes])

        // Restore the detail nav view controller for split screen
        return detailNavController
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
            if completed {
                self.pageViewController.scrollDelegate = nil
                DispatchQueue.main.async {
                    self.selectedViewController = currentVC
                    self.pageViewController.scrollDelegate = self
                }
            }
        }
    }
}

// MARK: - ScrollAwarePageViewControllerDelegate methods
extension SidebarSplitViewController: ScrollAwarePageViewControllerDelegate {
    public func pageViewScrollOffset() -> CGFloat {
        if let scrollView = pageViewController.scrollView {
            return scrollView.contentOffset.x - view.frame.size.width
        }
        return 0
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isCompact() {
            // Update the horizontal scrollbar to match the page view
            let percentOffset = pageViewScrollOffset() / view.frame.size.width
            compactSidebarViewController.setScrollOffsetPercent(percentOffset)
        }
    }
}

