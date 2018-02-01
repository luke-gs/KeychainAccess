//
//  EventSplitViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class EventSplitViewController: SidebarSplitViewController, EvaluationObserverable {

    public let viewModel: EventDetailViewModelType

    public required init(viewModel: EventDetailViewModelType) {
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
        if key == .readyToSubmit {
            //TODO: toggle submit button
        }
    }
}

public class DefaultEventsDetailViewModel: EventDetailViewModelType, Evaluatable {

    public var event: Event
    public var title: String?
    public var viewControllers: [UIViewController]?
    public var headerView: UIView?
    public var evaluator: Evaluator = Evaluator()

    private var readyToSubmit = false {
        didSet {
            evaluator.updateEvaluation(for: .readyToSubmit)
        }
    }

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

        event.evaluator.addObserver(self)
        evaluator.registerKey(.readyToSubmit) {
            return self.readyToSubmit
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        readyToSubmit = evaluationState
    }
}

fileprivate extension EvaluatorKey {
    static let readyToSubmit = EvaluatorKey(rawValue: "readyToSubmit")
}
