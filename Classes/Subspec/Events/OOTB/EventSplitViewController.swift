//
//  EventSplitViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class EventSplitViewController: SidebarSplitViewController {

    public let viewModel: EventDetailViewModelType

    public required init(viewModel: EventDetailViewModelType) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers ?? [])

        self.title = viewModel.title
        regularSidebarViewController.headerView = viewModel.headerView
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
}

public class DefaultEventsDetailViewModel: EventDetailViewModelType {

    public var event: Event
    public var title: String?
    public var viewControllers: [UIViewController]?
    public var headerView: UIView?

    public required init(event: Event, builder: EventScreenBuilding = DefaultEventScreenBuilder()) {
        self.event = event
        self.title = "New Event"

        self.viewControllers = builder.viewControllers(for: event.reports)
        self.headerView = {
            let header = SidebarHeaderView()
            header.iconView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconPencil)
            header.titleLabel.text = "No incident selected"
            header.captionLabel.text = "IN PROGRESS"
            return header
        }()
    }
}

