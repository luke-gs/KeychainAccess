//
//  EventEntityDetailsSplitViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

class EventEntityDetailsSplitViewController: SidebarSplitViewController {

    var viewModel: EventEntityDetailViewModel

    init(viewModel: EventEntityDetailViewModel) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers())

        regularSidebarViewController.headerView = viewModel.headerView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
