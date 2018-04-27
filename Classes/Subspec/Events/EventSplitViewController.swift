//
//  EventSplitViewController.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public extension EvaluatorKey {
    static let eventReadyToSubmit = EvaluatorKey(rawValue: "eventReadyToSubmit")
}

public class EventSplitViewController: SidebarSplitViewController, EvaluationObserverable {

    public let viewModel: EventDetailViewModelType

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public required init(viewModel: EventDetailViewModelType) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers ?? [])

        self.title = viewModel.title
        regularSidebarViewController.headerView = viewModel.headerView
        regularSidebarViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitEvent))

        viewModel.evaluator.addObserver(self)
        viewModel.headerUpdated = { [weak self] in
            let selectedRow = self?.regularSidebarViewController.sidebarTableView?.indexPathForSelectedRow
            self?.regularSidebarViewController.sidebarTableView?.reloadData()
            self?.regularSidebarViewController.sidebarTableView?.selectRow(at: selectedRow,
                                                                           animated: false,
                                                                           scrollPosition: .none)
        }

        setSubmitButtonEnabled(false)
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        if key == .eventReadyToSubmit {
            setSubmitButtonEnabled(evaluationState)
        }
    }

    // MARK: Private
    private func setSubmitButtonEnabled(_ state: Bool) {
        regularSidebarViewController.navigationItem.rightBarButtonItem?.isEnabled = state

        //TODO: Remove IF not needed
        #if DEBUG
        regularSidebarViewController.navigationItem.rightBarButtonItem?.isEnabled = true
        #endif
    }

    @objc
    private func submitEvent() {
        let builder = LoadingViewBuilder<Void>()
        builder.title = "Submitting event"
        builder.promise = firstly { () -> Promise<Void> in
            // TODO: Create network request, get content data and status data
            print("Submitted")
            return after(seconds: 10).asVoid()
        }
        
        LoadingViewController.presentWith(builder, from: self)?.done {
            print("DONE DONE DONE")
            }.catch { error in
                print(error)
        }
    }
}
