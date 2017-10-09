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

    public init(viewModel: TasksSplitViewModel) {

        self.viewModel = viewModel

        let masterVC = viewModel.taskListViewController
        let detailVC = viewModel.mapViewController

        super.init(masterViewController: masterVC, detailViewControllers: [detailVC])

        // Configure split to keep showing task list when compact, and to show header when regular
        shouldHideMasterWhenCompact = false
        containerMasterViewController.onlyVisibleWhenCompact = false

        // TODO: create masterViewControllerHeaderRegular for selected source header

        // TODO: create masterViewControllerHeaderCompact for selected source header
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        return viewModel.navTitle()
    }
}
