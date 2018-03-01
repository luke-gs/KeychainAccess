//
//  EventSplitViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public extension EvaluatorKey {
    static let eventReadyToSubmit = EvaluatorKey(rawValue: "eventReadyToSubmit")
}

public class EventSplitViewController: SidebarSplitViewController, EvaluationObserverable {

    public let viewModel: EventDetailViewModelType

    public required init(viewModel: EventDetailViewModelType) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers ?? [])

        self.title = viewModel.title
        regularSidebarViewController.headerView = viewModel.headerView

        viewModel.evaluator.addObserver(self)
        viewModel.headerUpdated = { [weak self] in
            self?.regularSidebarViewController.sidebarTableView?.reloadData()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        if key == .eventReadyToSubmit {
            //TODO: toggle submit button
        }
    }
}

public class IncidentSplitViewController: SidebarSplitViewController, EvaluationObserverable {

    public let viewModel: IncidentDetailViewModelType

    public required init(viewModel: IncidentDetailViewModelType) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers ?? [])

        self.title = viewModel.title
        regularSidebarViewController.headerView = viewModel.headerView

        viewModel.evaluator.addObserver(self)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        if key == .eventReadyToSubmit {
            //TODO: toggle submit button
        }
    }
}
