//
//  TasksSplitViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// Split view for top level of CAD application, displaying table of tasks on left and map on right
open class TasksSplitViewController: MPOLSplitViewController {

    private static let defaultSplitWidth: CGFloat = 320

    open let viewModel: TasksSplitViewModel

    open let masterVC: UIViewController
    open let detailVC: UIViewController
    open let segmentedControl: UISegmentedControl
    open let tasksListContainer: LoadableViewController?

    private var filterButton: UIBarButtonItem {
        return UIBarButtonItem(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showMapLayerFilter))
    }
    
    public init(viewModel: TasksSplitViewModel) {

        masterVC = viewModel.createMasterViewController()
        detailVC = viewModel.createDetailViewController()

        self.viewModel = viewModel
        self.tasksListContainer = masterVC as? LoadableViewController

        segmentedControl = UISegmentedControl(items: [viewModel.masterSegmentTitle(), viewModel.detailSegmentTitle()])
        segmentedControl.selectedSegmentIndex = 0
        
        super.init(masterViewController: masterVC, detailViewControllers: [detailVC])

        // Configure split to keep showing task list when compact
        shouldHideMasterWhenCompact = false
        
        // Change view when changing segmented control value
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tasksListContainer?.loadingManager.state = .loading

        // Sync data needed for displaying main UI, making master VC full width until loaded
        setMasterWidth(view.bounds.width, animated: false)
        firstly {
            return CADStateManager.shared.syncInitial()
        }.then { [weak self] () -> Void in
            self?.setMasterWidth(TasksSplitViewController.defaultSplitWidth)
            self?.tasksListContainer?.loadingManager.state = .loaded
        }.catch { [weak self] error in
            // TODO: add support for error state to loading state manager
            self?.tasksListContainer?.loadingManager.state = .noContent
            print("Failed to sync: \(error)")
        }
    }

    open func setMasterWidth(_ width: CGFloat, animated: Bool = true) {
        if animated {
            // Animate the split moving as well as the content fading in
            self.tasksListContainer?.loadingManager.contentView?.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.embeddedSplitViewController.minimumPrimaryColumnWidth = width
                self.embeddedSplitViewController.maximumPrimaryColumnWidth = width
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    self.tasksListContainer?.loadingManager.contentView?.alpha = 1
                })
            })
        } else {
            self.embeddedSplitViewController.minimumPrimaryColumnWidth = width
            self.embeddedSplitViewController.maximumPrimaryColumnWidth = width
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update master to still be fullscreen if device is rotated
        if embeddedSplitViewController.minimumPrimaryColumnWidth > TasksSplitViewController.defaultSplitWidth {
            setMasterWidth(size.width)
        }
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
