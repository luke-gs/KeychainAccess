//
//  TasksSplitViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol TasksSplitViewControllerDelegate {
    func willChangeSplitWidth(from oldSize: CGFloat, to newSize: CGFloat)
    func didChangeSplitWidth(from oldSize: CGFloat, to newSize: CGFloat)
}

/// Split view for top level of CAD application, displaying table of tasks on left and map on right
open class TasksSplitViewController: MPOLSplitViewController {
    
    public static let defaultSplitWidth: CGFloat = 320

    open let viewModel: TasksSplitViewModel

    open let masterVC: UIViewController
    open let detailVC: UIViewController
    open let segmentedControl: UISegmentedControl
    open let tasksListContainer: LoadableViewController?
    open var masterRightButtonItems: [UIBarButtonItem]?

    open private(set) var syncIntervalTimer: Timer?

    private var filterButton: UIBarButtonItem {
        return UIBarButtonItem(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showMapLayerFilter))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public init(viewModel: TasksSplitViewModel) {

        masterVC = viewModel.createMasterViewController()
        detailVC = viewModel.createDetailViewController()

        self.viewModel = viewModel
        self.tasksListContainer = masterVC as? LoadableViewController

        masterRightButtonItems = masterVC.navigationItem.rightBarButtonItems
        segmentedControl = UISegmentedControl(items: [viewModel.masterSegmentTitle(), viewModel.detailSegmentTitle()])
        segmentedControl.selectedSegmentIndex = 0
        
        super.init(masterViewController: masterVC, detailViewControllers: [detailVC])

        // Configure split to keep showing task list when compact
        shouldHideMasterWhenCompact = false
        
        // Change view when changing segmented control value
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControl(for: nil)

        self.performInitialSync()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Setup timer for interval updates
        syncIntervalTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSyncIntervalText), userInfo: nil, repeats: true)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Cancel timer
        syncIntervalTimer?.invalidate()
        syncIntervalTimer = nil
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update master to still be fullscreen if device is rotated
        if embeddedSplitViewController.minimumPrimaryColumnWidth > TasksSplitViewController.defaultSplitWidth {
            setMasterWidth(size.width)
        }
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        configureSegmentedControl(for: newCollection)
    }

    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        return viewModel.navTitle()
    }

    open override func masterNavSubtitleSuitable(for traitCollection: UITraitCollection) -> String? {
        if let intervalString = CADStateManager.shared.lastSyncTime?.elapsedTimeIntervalForHuman() {
            return "Updated \(intervalString)"
        }
        return nil
    }

    open override func defaultSelectedViewController() -> UIViewController? {
        // No default selection is wanted for this view controller.
        return nil
    }

    @objc open func updateSyncIntervalText() {
        updateNavigationBarForSelection()
    }

    open func setMasterWidth(_ width: CGFloat, animated: Bool = true, completion: ((Bool) -> Swift.Void)? = nil) {
        var oldWidth = embeddedSplitViewController.maximumPrimaryColumnWidth
        if oldWidth == UISplitViewControllerAutomaticDimension {
            oldWidth = 0
        }
        
        (detailVC as? TasksSplitViewControllerDelegate)?.willChangeSplitWidth(from: oldWidth, to: width)
        if animated {
            // Animate the split moving
            UIView.animate(withDuration: 0.3, animations: {
                self.embeddedSplitViewController.minimumPrimaryColumnWidth = width
                self.embeddedSplitViewController.maximumPrimaryColumnWidth = width
            }, completion: completion)
        } else {
            self.embeddedSplitViewController.minimumPrimaryColumnWidth = width
            self.embeddedSplitViewController.maximumPrimaryColumnWidth = width
            completion?(true)
        }
        (detailVC as? TasksSplitViewControllerDelegate)?.didChangeSplitWidth(from: oldWidth, to: width)
    }

    private func performInitialSync() {
        tasksListContainer?.loadingManager.state = .loading

        // Sync data needed for displaying main UI, making master VC full width until loaded
        setMasterWidth(view.bounds.width, animated: false)

        // Disable navigation bar items
        let barButtonArrays = [masterVC.navigationItem.leftBarButtonItems,
                               masterVC.navigationItem.rightBarButtonItems,
                               detailVC.navigationItem.leftBarButtonItems,
                               detailVC.navigationItem.rightBarButtonItems].removeNils()
        let barButtonItems = barButtonArrays.flatMap { return $0 }
        barButtonItems.forEach { $0.isEnabled = false }

        firstly {
            return CADStateManager.shared.syncInitial()
        }.then { [weak self] () -> Void in
            // Hide the content view
            self?.tasksListContainer?.loadingManager.contentView?.alpha = 0

            // Show full split screen
            self?.setMasterWidth(TasksSplitViewController.defaultSplitWidth, animated: true, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
                    // Remove loading state and animate content back in
                    self?.tasksListContainer?.loadingManager.state = .loaded
                    self?.tasksListContainer?.loadingManager.contentView?.alpha = 1
                }, completion: nil)
            })
            // Enable navigation bar items
            barButtonItems.forEach { $0.isEnabled = true }

            // Reload header text for time since sync
            self?.updateSyncIntervalText()

            // Zoom to user location
            self?.viewModel.mapViewModel.delegate?.zoomToUserLocation()

        }.catch { [weak self] error in
            self?.tasksListContainer?.loadingManager.state = .error
            self?.tasksListContainer?.loadingManager.errorView.subtitleLabel.text = error.localizedDescription
            print("Failed to sync: \(error)")
        }
    }

    // MARK: - Segmented control
    
    /// Shows or hides the segmented control based on trait collection passed in.
    /// If `nil` is passed in, the current trait collection will be used.
    private func configureSegmentedControl(for traitCollection: UITraitCollection?) {
        if traitCollection?.horizontalSizeClass == .compact || (traitCollection == nil && isCompact()) {
            masterVC.navigationItem.titleView = segmentedControl
            
            masterVC.navigationItem.rightBarButtonItem = filterButton
            detailVC.navigationItem.rightBarButtonItem = filterButton
        } else {
            masterVC.navigationItem.rightBarButtonItems = masterRightButtonItems
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

// MARK: - TasksSplitViewModelDelegate
extension TasksSplitViewController: TasksSplitViewModelDelegate {
    open func sectionsUpdated() {
        // Reload header text for time since sync
        updateSyncIntervalText()
    }
}

