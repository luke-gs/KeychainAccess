//
//  IncidentSplitViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 1/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

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

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
