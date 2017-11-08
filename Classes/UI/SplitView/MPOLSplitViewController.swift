//
//  MPOLSplitViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 6/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Base class for generic MPOL split views that behave differently based on current trait collection size
///
/// - In regular mode, the provided regular header is used in the master nav controller and navigation is
/// provided by the content of the master view controller.
///
/// - In compact mode, the provided compact header is used in the master nav controller and navigation is
/// provided by the header itself or via page gestures on detail view controllers.
///
open class MPOLSplitViewController: PushableSplitViewController {

    // MARK: - Properties

    // The navigation controller for the master side of split view
    public let masterNavController: UINavigationController

    // The navigation controller for the detail side of split view
    public let detailNavController: UINavigationController

    // The page view controller for handling compact mode paging behaviour
    public let pageViewController: ScrollAwarePageViewController

    /// The container view controller for showing the master view controller, along with an optional header
    public let containerMasterViewController: ContainerWithHeaderViewController

    /// The master view controller for the split
    public let masterViewController: UIViewController

    /// The detail view controllers for the split
    public var detailViewControllers: [UIViewController]

    /// The current master view controller header
    public private(set) var masterViewControllerHeader: UIViewController? {
        didSet {
            if masterViewControllerHeader != oldValue {
                containerMasterViewController.headerViewController = masterViewControllerHeader
            }
        }
    }

    /// The master view controller header when displayed in regular mode, set by subclass
    public var masterViewControllerHeaderRegular: UIViewController? {
        didSet {
            if masterViewControllerHeaderRegular != oldValue {
                updateHeaderViewController()
            }
        }
    }

    /// The master view controller header when displayed in compact mode, set by subclass
    public var masterViewControllerHeaderCompact: UIViewController? {
        didSet {
            if masterViewControllerHeaderCompact != oldValue {
                updateHeaderViewController()
            }
        }
    }

    /// Whether the master view controller is hidden when displaying in compact size
    public var shouldHideMasterWhenCompact: Bool = true

    /// The KVO observer for right bar button items of the selected view controller
    private var rightBarButtonItemsObservation: NSKeyValueObservation?

    /// The selected view controller.
    public var selectedViewController: UIViewController? {
        didSet {
            if selectedViewController != oldValue {
                selectedViewControllerDidChange(oldValue: oldValue)
            }
        }
    }

    // MARK: - Subclass

    /// Return the title to use for the master navigation controller for the given traits
    open func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        return self.title ?? ""
    }

    /// Notification that paging scroll view has updated
    open func updatedPagingScrollView(percentOffset: CGFloat) {
        // For subclasses
    }

    /// Return the default selected view controller
    open func defaultSelectedViewController() -> UIViewController? {
        return detailViewControllers.first
    }

    // MARK: - Init

    public init(masterViewController: UIViewController, detailViewControllers: [UIViewController]) {
        self.masterViewController = masterViewController
        self.detailViewControllers = detailViewControllers
        self.containerMasterViewController = ContainerWithHeaderViewController()

        // Set up the page controller
        pageViewController = ScrollAwarePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = UIColor.white

        masterNavController = UINavigationController(rootViewController: containerMasterViewController)
        detailNavController = UINavigationController()

        super.init(viewControllers: [masterNavController, detailNavController])

        // Handle all page view delegates
        pageViewController.scrollDelegate = self
        pageViewController.dataSource = self
        pageViewController.delegate = self

        // Configure split view
        let embeddedSplitViewController = self.embeddedSplitViewController
        embeddedSplitViewController.delegate = self
        embeddedSplitViewController.minimumPrimaryColumnWidth = 288.0
        embeddedSplitViewController.preferredPrimaryColumnWidthFraction = 320.0 / 1024.0
        embeddedSplitViewController.delegate = self

        // Force early application of trait collection so presentation animation looks good
        updateSplitViewControllerForTraitChange()

        // Get the default selected view controller from the subclass and apply the selection
        selectedViewController = defaultSelectedViewController()
        selectedViewControllerDidChange(oldValue: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarForTraitChange()
    }

    // MARK: - Convenience

    /// Is the split view controller being rendered in compact environment, hence collapsed
    public func isCompact() -> Bool {
        // If it is called early enough, `self.traitCollection.horizontalSizeClass` will return .unspecified.
        // It'll inherit the value from upper chain so delegate that to the window.
        if self.traitCollection.horizontalSizeClass != .unspecified {
            return self.traitCollection.horizontalSizeClass == .compact
        }
        return MPOLSplitViewController.isWindowCompact()
    }

    /// Is the key window being rendered in compact environment
    public static func isWindowCompact() -> Bool {
        if let traitCollection = UIApplication.shared.keyWindow?.rootViewController?.traitCollection,
            traitCollection.horizontalSizeClass == .compact {
            return true
        }
        return false
    }

    // MARK: - Selection

    private func selectedViewControllerDidChange(oldValue: UIViewController?) {
        // Clear previous observer for navigations items
        rightBarButtonItemsObservation?.invalidate()
        rightBarButtonItemsObservation = nil

        if let newValue = selectedViewController {
            precondition(detailViewControllers.contains(newValue), "`selectedViewController` must be a member of detailViewControllers.")

            // Use KVO to observe changes to the selected view controllers navigation items
            rightBarButtonItemsObservation = newValue.navigationItem.observe(\.rightBarButtonItems) { [unowned self] (navItem, change) in
                self.updateNavigationBarForSelection()
            }
        }
        // Update the split view content
        updateSplitViewControllerForSelection()
    }

    // MARK: - Adaptive UI Support

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            // Update header bar and split view controller for new trait
            self.updateSplitViewControllerForTraitChange()
            self.updateNavigationBarForTraitChange()
            }, completion: nil)
    }

    open func updateSplitViewControllerForTraitChange() {
        guard let detailViewController = self.selectedViewController ?? self.detailViewControllers.first else { return }
        if isCompact() && shouldHideMasterWhenCompact {
            // Split displayed as single view, with details collapsed on top of master
            if containerMasterViewController.contentViewController != pageViewController {
                // Clear old state
                detailNavController.viewControllers = []

                // Use the paging view controller in the master nav controller
                pageViewController.setViewControllers([detailViewController], direction: .forward, animated: false, completion: nil)
                containerMasterViewController.contentViewController = pageViewController
            }
        } else {
            // Split displayed as both views visible at same time
            if containerMasterViewController.contentViewController != masterViewController {
                // Clear old state
                pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)

                // Use the regular sidebar view controller in the master nav controller
                containerMasterViewController.contentViewController = masterViewController
                detailNavController.viewControllers = [detailViewController]
            }
        }
        // Switch header if necessary
        updateHeaderViewController()
    }

    open func updateSplitViewControllerForSelection() {
        // Update the visible view controller
        if let selectedViewController = selectedViewController {
            if self.isCompact() && shouldHideMasterWhenCompact {
                // Only set the VC if it's not the current one, in case page scroll has already made it visible
                // This improves the animations when flicking pages fast
                if pageViewController.viewControllers?.first != selectedViewController {
                    // Fade in view if not previously loaded
                    if !selectedViewController.isViewLoaded {
                        selectedViewController.view.alpha = 0
                    }
                    UIView.transition(with: pageViewController.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        selectedViewController.view.alpha = 1
                        self.pageViewController.setViewControllers([selectedViewController], direction: .forward, animated: false, completion: nil)
                    }, completion: nil)
                }
            } else {
                detailNavController.viewControllers = [selectedViewController]
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
            }
        } else if let defaultViewController = defaultSelectedViewController() {
            // No current selection, use default detail if compact
            if self.isCompact() {
                pageViewController.setViewControllers([defaultViewController], direction: .forward, animated: false, completion: nil)
            } else {
                detailNavController.viewControllers = []
                embeddedSplitViewController.showDetailViewController(detailNavController, sender: self)
            }
        }
        updateNavigationBarForSelection()
    }

    open func updateNavigationBarForSelection() {
        let masterNavItem = containerMasterViewController.navigationItem
        let detailNavItem = detailNavController.viewControllers.first?.navigationItem

        // Make sure the current master view controller has the back button
        // Note: this can move to detail view controller when switching between regular and compact
        masterNavItem.leftBarButtonItems = [backButtonItem()].removeNils()
        detailNavItem?.leftBarButtonItem = nil

        if self.isCompact() {
            // Use the selected detail right button items if compact
            masterNavItem.rightBarButtonItems = selectedViewController?.navigationItem.rightBarButtonItems
        } else {
            // Otherwise use the content of the master view controller
            masterNavItem.rightBarButtonItems = containerMasterViewController.contentViewController?.navigationItem.rightBarButtonItems
        }

        // Update the navigation bar titles, otherwise they can be shown on wrong side after transition
        masterNavItem.title = masterNavTitleSuitable(for: traitCollection)
        detailNavItem?.title = detailNavController.viewControllers.first?.title
    }

    open func updateNavigationBarForTraitChange() {
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
    
    open func updateHeaderViewController() {
        // Update the current header based on the size class
        // We use window here as can be called before view is initialised
        masterViewControllerHeader = MPOLSplitViewController.isWindowCompact() ? masterViewControllerHeaderCompact : masterViewControllerHeaderRegular
    }

    // MARK: - UISplitViewControllerDelegate methods

    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return isCompact()
    }

    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        // Restore the detail nav view controller for split screen
        return detailNavController
    }

}

// MARK: - UIPageViewControllerDataSource methods
extension MPOLSplitViewController: UIPageViewControllerDataSource {

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
extension MPOLSplitViewController: UIPageViewControllerDelegate {
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
extension MPOLSplitViewController: ScrollAwarePageViewControllerDelegate {
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
            updatedPagingScrollView(percentOffset: percentOffset)
        }
    }
}


