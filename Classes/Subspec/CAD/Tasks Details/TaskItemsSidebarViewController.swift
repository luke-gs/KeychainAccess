//
//  TasksItemSidebarViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksItemSidebarViewController: SidebarSplitViewController {
    
    private let headerView = SidebarHeaderView(frame: .zero)
    private let detailViewModel: TaskItemViewModel

    // Appearance properties
    
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
    
    public init(viewModel: TaskItemViewModel) {
        
        detailViewModel = viewModel
        
        super.init(detailViewControllers: detailViewModel.detailViewControllers())
        
        title = "Details"
        updateHeaderView()
        
        regularSidebarViewController.title = NSLocalizedString("Details", comment: "")
        regularSidebarViewController.headerView = headerView
        
        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController {
//            detailViewModel.performFetch()
        }
    }
    
    
    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        // Ask the data source for an appropriate title
        if traitCollection.horizontalSizeClass == .compact {
            if let title = detailViewModel.itemName {
                return title
            }
        }
        
        // Use a generic sidebar title
        return NSLocalizedString("Details", comment: "Title for for entity details")
    }
    
    /// Updates the header view with the details for the latest selected representation.
    /// Call this methodwhen the selected representation changes.
    fileprivate func updateHeaderView() {
        headerView.iconView.image = detailViewModel.iconImage
        headerView.iconView.contentMode = .center // TODO: Something here
        headerView.captionLabel.text = detailViewModel.statusText?.localizedUppercase
        headerView.titleLabel.text = detailViewModel.itemName
        
        if let lastUpdated = detailViewModel.lastUpdated {
            headerView.subtitleLabel.text = lastUpdated
        } else {
            headerView.subtitleLabel.text = nil
        }
        
        if let color = detailViewModel.color {
            headerView.iconView.backgroundColor = color
            headerView.captionLabel.textColor = color
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

}
