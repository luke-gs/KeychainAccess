//
//  EventSplitViewController.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import PatternKit

public protocol EventSplitViewControllerDelegate: class {
    /// An event was just closed
    func eventClosed(eventId: String)

    /// An event was submitted
    func eventSubmittedFor(eventId: String, response: Any?, error: Error?)
}

public class EventSplitViewController<Response: EventSubmittable>: SidebarSplitViewController, EventSummaryViewControllerDelegate, EventSubmitter {

    public let viewModel: EventDetailViewModelType
    public weak var delegate: EventSplitViewControllerDelegate?
    public var loadingViewBuilder: LoadingViewBuilder<Response>?

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public required init(viewModel: EventDetailViewModelType) {
        self.viewModel = viewModel
        super.init(detailViewControllers: viewModel.viewControllers ?? [])

        detailViewControllers.forEach { (vc) in
            if let vc = vc as? DefaultEventNotesMediaViewController {
                vc.delegate = self
            }
        }

        self.title = viewModel.title
        regularSidebarViewController.headerView = viewModel.headerView
        regularSidebarViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit",
                                                                                         style: .plain,
                                                                                         target: self,
                                                                                         action: #selector(presentEventSummary))

        viewModel.headerUpdated = { [weak self] in
            let selectedRow = self?.regularSidebarViewController.sidebarTableView?.indexPathForSelectedRow
            self?.regularSidebarViewController.sidebarTableView?.reloadData()
            self?.regularSidebarViewController.sidebarTableView?.selectRow(at: selectedRow,
                                                                           animated: false,
                                                                           scrollPosition: .none)
        }
    }

    deinit {
        // Notify delegate that event was closed
        delegate?.eventClosed(eventId: viewModel.event.id)
    }

    // TODO: Fix the EventSubmitter protocol and make this private again.
    @objc
    public func presentEventSummary() {
        let summaryController = EventSummaryViewController(viewModel: EventSummaryViewModel(event: viewModel.event), submitButtonIsEnabled: viewModel.evaluator.isComplete)
        summaryController.delegate = self
        let popoverController = PopoverNavigationController(rootViewController: summaryController)
        popoverController.modalPresentationStyle = .pageSheet
        present(popoverController, animated: true)
    }

    func submitEvent(controller: EventSummaryViewController) {
        guard let builder = self.loadingViewBuilder else { return }
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
        let action = DialogAction(title: "OK", style: .cancel) { [weak self] _ in
            guard let `self` = self else { return }
            self.delegate?.eventSubmittedFor(eventId: eventId, response: result, error: error)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        AlertQueue.shared.add(alert)
    }
}
