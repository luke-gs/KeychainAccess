//
//  TasksSplitViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Split view for top level of CAD application, displaying table of tasks on left and map on right
open class TasksSplitViewController: MPOLSplitViewController, MapFilterPresenter {

    public let viewModel: TasksSplitViewModel

    public init(viewModel: TasksSplitViewModel) {

        self.viewModel = viewModel

        let masterVC = viewModel.createMasterViewController()
        let detailVC = viewModel.createDetailViewController()

        super.init(masterViewController: masterVC, detailViewControllers: [detailVC])

        // Configure split to keep showing task list when compact
        shouldHideMasterWhenCompact = false
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        return viewModel.navTitle()
    }
}

extension TasksSplitViewController: MapFilterViewControllerDelegate {
    public func didSelectDone() {
        viewModel.applyFilter()
    }
}
