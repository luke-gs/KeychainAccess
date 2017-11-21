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
    open let tasksListContainer: LoadableViewController?

    public init(viewModel: TasksSplitViewModel) {

        let masterVC = viewModel.createMasterViewController()
        let detailVC = viewModel.createDetailViewController()

        self.viewModel = viewModel
        self.tasksListContainer = masterVC as? LoadableViewController

        super.init(masterViewController: masterVC, detailViewControllers: [detailVC])

        // Configure split to keep showing task list when compact
        shouldHideMasterWhenCompact = false
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
}
