//
//  EventSplitViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class EventSplitViewController: SidebarSplitViewController {

    private let headerView: UIView?
    public let event: Event
    public let viewModel: EventDetailViewModelType

    public required init(viewModel: EventDetailViewModelType) {
        self.viewModel = viewModel
        self.event = viewModel.event
        self.headerView = viewModel.headerView

        super.init(detailViewControllers: viewModel.viewControllers)
        self.title = viewModel.title

        regularSidebarViewController.title = NSLocalizedString("Details", comment: "")
        regularSidebarViewController.headerView = headerView
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
}
