//
//  EventsModels.swift
//  MPOLKitDemo
//
//  Created by Pavel Boryseiko on 31/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

class DemoListViewModel: EventListViewModelType {
    var title: String = "Events"

    var eventsList: [EventListDisplayable]?
    var eventsManager: EventsManager

    required init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
    }

    func event(for displayable: EventListDisplayable) -> Event? {
        return self.eventsManager.event(for: displayable.id)
    }

    func detailsViewModel(for event: Event) -> EventDetailViewModelType {
        return DemoDetailsViewModel(event: event, builder: DemoScreenBuilder())
    }
}

class DemoDetailsViewModel: EventDetailViewModelType {

    var event: Event
    var title: String?
    var viewControllers: [UIViewController]?
    var headerView: UIView?

    var evaluator: Evaluator = Evaluator()

    required init(event: Event, builder: EventScreenBuilding) {
        self.event = event
        self.title = "Details"
        self.viewControllers = builder.viewControllers(for: event.reports)
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}

class DemoScreenBuilder: EventScreenBuilding {

    init() { }

    func viewControllers(for reportables: [Reportable]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        for report in reportables {
            switch report {
            case let report as DefaultDateTimeReport:
                viewControllers.append(DefaultEventDateTimeViewController(report: report))
            default:
                break
            }
        }

        return viewControllers
    }
}
