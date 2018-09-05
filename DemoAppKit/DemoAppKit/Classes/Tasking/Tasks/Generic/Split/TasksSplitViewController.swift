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
    func didFinishAnimatingSplitWidth()
}

/// Split view for top level of CAD application, displaying table of tasks on left and map on right
open class TasksSplitViewController: MPOLSplitViewController {
    
    public static let defaultSplitWidth: CGFloat = 320
    public let extendedNavbarHeight: CGFloat = 44
    
    public let viewModel: TasksSplitViewModel

    public let masterVC: UIViewController
    public let detailVC: UIViewController
    public let segmentedControl: UISegmentedControl
    public let tasksListContainer: LoadableViewController?
    open var masterRightButtonItems: [UIBarButtonItem]?
    private var compactNavBarExtension: NavigationBarExtension?

    open private(set) var syncIntervalTimer: Timer?

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

        let navBarExtension = NavigationBarExtension(frame: .zero)
        navBarExtension.translatesAutoresizingMaskIntoConstraints = false
        navBarExtension.contentView = segmentedControl
        masterNavController.view.addSubview(navBarExtension)
        
        compactNavBarExtension = navBarExtension

        NSLayoutConstraint.activate([
            navBarExtension.topAnchor.constraint(equalTo: masterNavController.navigationBar.bottomAnchor),
            navBarExtension.leadingAnchor.constraint(equalTo: masterNavController.view.leadingAnchor),
            navBarExtension.trailingAnchor.constraint(equalTo: masterNavController.view.trailingAnchor),
            navBarExtension.heightAnchor.constraint(equalToConstant: extendedNavbarHeight),
            
            segmentedControl.topAnchor.constraint(equalTo: navBarExtension.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: navBarExtension.leadingAnchor, constant: 24),
            segmentedControl.trailingAnchor.constraint(equalTo: navBarExtension.trailingAnchor, constant: -24),
            segmentedControl.bottomAnchor.constraint(equalTo: navBarExtension.bottomAnchor, constant: -10),
        ])        
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        compactNavBarExtension?.isHidden = !isCompact()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

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
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = isCompact() ? extendedNavbarHeight : 0
        if #available(iOS 11, *) {
            masterNavController.additionalSafeAreaInsets.top = height
        } else {
            containerMasterViewController.headerOffset = masterNavController.navigationBar.frame.maxY + height
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update master to still be fullscreen if device is rotated
        if embeddedSplitViewController.minimumPrimaryColumnWidth > TasksSplitViewController.defaultSplitWidth {
            setMasterWidth(size.width)
        }
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

    @objc private func performInitialSync() {
        tasksListContainer?.loadingManager.state = .loading
        tasksListContainer?.loadingManager.loadingView.userInterfaceStyle = .dark

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
        }.done { [weak self] () -> Void in
            // Hide the content view
            self?.tasksListContainer?.loadingManager.contentView?.alpha = 0

            // Show full split screen
            self?.setMasterWidth(TasksSplitViewController.defaultSplitWidth, animated: true, completion: { _ in
                (self?.detailVC as? TasksSplitViewControllerDelegate)?.didFinishAnimatingSplitWidth()
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
            self?.tasksListContainer?.loadingManager.errorView.userInterfaceStyle = .dark
            self?.tasksListContainer?.loadingManager.errorView.subtitleLabel.text = error.localizedDescription
            self?.tasksListContainer?.loadingManager.errorView.actionButton.setTitle(NSLocalizedString("Try Again", comment: ""), for: .normal)
            self?.tasksListContainer?.loadingManager.errorView.actionButton.addTarget(self, action: #selector(self?.performInitialSync), for: .touchUpInside)
            print("Failed to sync: \(error)")

            // Enable navigation bar items, for logoff
            barButtonItems.forEach { $0.isEnabled = true }
        }
    }

    // MARK: - Segmented control

    /// Called when the segmented control value changed
    @objc private func didChangeSegmentedControl() {
        shouldHideMasterWhenCompact = segmentedControl.selectedSegmentIndex != 0
        if shouldHideMasterWhenCompact {
            selectedViewController = nil
        }
    }
}

// MARK: - TasksSplitViewModelDelegate
extension TasksSplitViewController: TasksSplitViewModelDelegate {
    open func sectionsUpdated() {
        // Reload header text for time since sync
        updateSyncIntervalText()
    }
}

