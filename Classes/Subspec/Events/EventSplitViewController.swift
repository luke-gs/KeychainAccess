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

public class EventSplitViewController<Response: EventSubmittable>: SidebarSplitViewController, EvaluationObserverable {
    public let viewModel: EventDetailViewModelType
    public var delegate: EventsSubmissionDelegate?
    public var loadingViewBuilder: LoadingViewBuilder<Response>?
    
    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public required init(viewModel: EventDetailViewModelType) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers ?? [])
        
        self.title = viewModel.title
        regularSidebarViewController.headerView = viewModel.headerView
        regularSidebarViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit",
                                                                                         style: .plain,
                                                                                         target: self,
                                                                                         action: #selector(submitEvent))
        
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
        
        //TODO: Remove if not needed
        #if DEBUG
        regularSidebarViewController.navigationItem.rightBarButtonItem?.isEnabled = true
        #endif
    }
    
    @objc
    private func submitEvent() {
        guard let builder = loadingViewBuilder else { return }
        LoadingViewController.presentWith(builder, from: self)?
            .done { result in
                self.eventSubmittedFor(eventId: self.viewModel.event.id, result: result, error: nil)
            }.catch { error in
                self.eventSubmittedFor(eventId: self.viewModel.event.id, result: nil, error: error)
        }
    }
    
    private func eventSubmittedFor(eventId: String, result: Response?, error: Error?) {
        let title = error != nil ? "Submission Failed" : result?.title
        let detail = error?.localizedDescription ?? result?.detail

        let alert = PSCAlertController(title: title, message: detail, image: nil)
        let action = PSCAlertAction(title: "OK", style: .cancel) { _ in
            self.delegate?.eventSubmittedFor(eventId: eventId, response: result, error: error)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        AlertQueue.shared.add(alert)
    }
}

public protocol EventsSubmissionDelegate {
    func eventSubmittedFor(eventId: String, response: Any?, error: Error?)
}
