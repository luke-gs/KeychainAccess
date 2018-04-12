//
//  EventSplitViewController.swift
//  MPOLKit
//
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
            let selectedRow = self?.regularSidebarViewController.sidebarTableView?.indexPathForSelectedRow
            self?.regularSidebarViewController.sidebarTableView?.reloadData()
            self?.regularSidebarViewController.sidebarTableView?.selectRow(at: selectedRow,
                                                                           animated: false,
                                                                           scrollPosition: .none)
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
