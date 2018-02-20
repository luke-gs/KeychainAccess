//
//  EventsDetailViewModel.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

public class EventsDetailViewModel: EventDetailViewModelType, Evaluatable {

    public var event: Event
    public var title: String?
    public var viewControllers: [UIViewController]?
    public var headerView: UIView?
    public var evaluator: Evaluator = Evaluator()

    private var readyToSubmit = false {
        didSet {
            evaluator.updateEvaluation(for: .eventReadyToSubmit)
        }
    }

    public required init(event: Event, builder: EventScreenBuilding) {
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
        evaluator.registerKey(.eventReadyToSubmit) {
            return self.readyToSubmit
        }

        setUpdateHeaderDelegate()
    }

    private func setUpdateHeaderDelegate() {
        for case let report as IncidentListReport in event.reports {
            report.headerDelegate = self
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        readyToSubmit = evaluationState
    }
}

extension EventsDetailViewModel: EventHeaderUpdateDelegate {
    public func updateHeader(with title: String?, subtitle: String?) {
        guard let header = headerView as? SidebarHeaderView else { return }
        header.titleLabel.text = title ?? "No incident selected"
        header.captionLabel.text = subtitle ?? "IN PROGRESS"
    }
}
