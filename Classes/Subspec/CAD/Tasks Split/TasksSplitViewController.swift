//
//  TasksSplitViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Split view for top level of CAD application, displaying table of tasks on left and map on right
open class TasksSplitViewController: MPOLSplitViewController {

    public let viewModel: TasksSplitViewModel
    private let masterVC: UIViewController
    private let detailVC: UIViewController
    private let segmentedControl: UISegmentedControl
    
    private var filterButton: UIBarButtonItem {
        return UIBarButtonItem(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showMapLayerFilter))
    }
    
    public init(viewModel: TasksSplitViewModel) {

        self.viewModel = viewModel

        masterVC = viewModel.createMasterViewController()
        detailVC = viewModel.createDetailViewController()
        
        segmentedControl = UISegmentedControl(items: [viewModel.masterSegmentTitle(), viewModel.detailSegmentTitle()])
        segmentedControl.selectedSegmentIndex = 0
        
        super.init(masterViewController: masterVC, detailViewControllers: [detailVC])

        // Configure split to keep showing task list when compact
        shouldHideMasterWhenCompact = false
        
        // Change view when changing segmented control value
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        return viewModel.navTitle()
    }
    
    open override func masterNavSubtitleSuitable(for traitCollection: UITraitCollection) -> String? {
        return "Updated 2 mins ago"
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        configureSegmentedControl(for: newCollection)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControl(for: traitCollection)
    }
    
    // MARK: - Segmented control
    
    /// Shows or hides the segmented control based on trait collection
    private func configureSegmentedControl(for traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .compact {
            masterVC.navigationItem.titleView = segmentedControl
            
            masterVC.navigationItem.rightBarButtonItem = filterButton
            detailVC.navigationItem.rightBarButtonItem = filterButton
        } else {
            masterVC.navigationItem.rightBarButtonItem = nil
            masterVC.navigationItem.titleView = nil
        }
    }
    
    /// Called when the segmented control value changed
    @objc private func didChangeSegmentedControl() {
        shouldHideMasterWhenCompact = segmentedControl.selectedSegmentIndex != 0
        if shouldHideMasterWhenCompact {
            selectedViewController = nil
        }
    }
    
    @objc private func showMapLayerFilter() {
        viewModel.presentMapFilter()
    }
}
