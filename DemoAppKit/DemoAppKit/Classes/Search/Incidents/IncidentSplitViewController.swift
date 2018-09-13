//
//  IncidentSplitViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class IncidentSplitViewController: SidebarSplitViewController, EvaluationObserverable {

    private(set) var viewModel: IncidentDetailViewModelType

    public required init(viewModel: IncidentDetailViewModelType) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers ?? [])

        self.title = viewModel.title
        regularSidebarViewController.headerView = viewModel.headerView

        self.viewModel.evaluator.addObserver(self)
        self.viewModel.headerUpdated = {
                let selectedRow = self.regularSidebarViewController.sidebarTableView?.indexPathForSelectedRow
                self.regularSidebarViewController.sidebarTableView?.reloadData()
                self.regularSidebarViewController.sidebarTableView?.selectRow(at: selectedRow,
                                                                         animated: false,
                                                                         scrollPosition: .none)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }
}

