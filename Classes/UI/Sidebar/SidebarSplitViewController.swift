//
//  SidebarSplitViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 10/2/17, edited by Trent Fitzgibbon.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The SidebarSplitViewController represents a standard split view controller that can be pushed on to
/// a UINavigationController stack and includes a sidebar of navigation menu items that can be displayed
/// in both regular and compact size environments.
///
/// The sidebar is a table master VC in regular mode, and a horizontal strip above a detail VC in compact mode
open class SidebarSplitViewController: MPOLSplitViewController, SidebarDelegate {
    
    /// The sidebar view controller when displayed horizontally in compact mode
    public var compactSidebarViewController = CompactSidebarViewController()

    /// The sidebar view controller for the split view controller.
    public let regularSidebarViewController = RegularSidebarViewController()

    /// The detail controllers for the sidebar.
    override public var detailViewControllers: [UIViewController] {
        didSet {
            // Clear the selected detail VC if no longer available
            if let oldSelected = selectedViewController, detailViewControllers.contains(oldSelected) == false {
                selectedViewController = nil
            }
            // Update sidebar items
            updateSidebarItems()
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

    /// Whether sources should be hidden, in both compact and regular sidebars
    public var hideSources: Bool = false {
        didSet {
            regularSidebarViewController.hideSourceBar = hideSources
            compactSidebarViewController.hideSourceButton = hideSources
        }
    }
    
    /// The user interface style for the collection view.
    ///
    /// When set to `.current`, the theme autoupdates when the interface
    /// style changes.
    open var userInterfaceStyle: UserInterfaceStyle = .current {
        didSet {
            if userInterfaceStyle == oldValue { return }
            
            if userInterfaceStyle == .current {
                NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
            } else if oldValue == .current {
                NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
            }
            
            apply(ThemeManager.shared.theme(for: userInterfaceStyle))
        }
    }

    public init(detailViewControllers: [UIViewController]) {

        // Use regular sidebar view controller as master VC
        super.init(masterViewController: regularSidebarViewController, detailViewControllers: detailViewControllers)

        // Create header sidebar for horizontal navigation, visible only when compact
        masterViewControllerHeaderCompact = compactSidebarViewController
        updateHeaderViewController()

        // Force potentially hidden compact sidebar view to load as part of init
        _ = compactSidebarViewController.view

        regularSidebarViewController.delegate = self
        compactSidebarViewController.delegate = self
        
        
        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Initialise sidebar menu items here, as no selection if done in init
        updateSidebarItems()
    }

    public func updateSidebarItems() {
        let sidebarItems = detailViewControllers.map { $0.sidebarItem }
        regularSidebarViewController.items = sidebarItems
        compactSidebarViewController.items = sidebarItems

        let selectedItem = selectedViewController?.sidebarItem
        regularSidebarViewController.selectedItem = selectedItem
        compactSidebarViewController.selectedItem = selectedItem
    }

    // MARK: - Subclass

    override open func updatedPagingScrollView(percentOffset: CGFloat) {
        compactSidebarViewController.setScrollOffsetPercent(percentOffset)
    }

    override open func defaultSelectedViewController() -> UIViewController? {
        // Use the first enabled sidebar item as the default selection
        return detailViewControllers.first { $0.sidebarItem.isEnabled }
    }

    override open func updateSplitViewControllerForSelection() {
        super.updateSplitViewControllerForSelection()

        // Update the highlighted sidebar menu item
        let selectedItem = selectedViewController?.sidebarItem
        regularSidebarViewController.selectedItem = selectedItem
        UIView.performWithoutAnimation {
            self.compactSidebarViewController.selectedItem = selectedItem
        }
    }

    // MARK: - Theme
    
    open func apply(_ theme: Theme) {
        pageViewController.view.backgroundColor = theme.color(forKey: .background)
    }
    
    // MARK: - Private methods
    @objc private func interfaceStyleDidChange() {
        if userInterfaceStyle != .current { return }
        
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }
    
    // MARK: - SidebarDelegate methods

    open func sidebarViewController(_ controller: UIViewController?, didSelectItem item: SidebarItem) {
        selectedViewController = detailViewControllers.first(where: { $0.sidebarItem == item })
    }

    open func sidebarViewController(_ controller: UIViewController, didSelectSourceAt index: Int) {
    }

    open func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int) {

    }
}
