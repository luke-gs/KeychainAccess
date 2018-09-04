//
//  EventsModels.swift
//  MPOLKitDemo
//
//  Created by Pavel Boryseiko on 31/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//



public class DemoListViewModel {
    var title: String = "Events"

    var eventsList: [EventListDisplayable]? {
        return eventsManager.displayableBucket.objects
    }
    var eventsManager: EventsManager

    public required init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
    }

    func event(for displayable: EventListDisplayable) -> Event? {
        return eventsManager.event(for: displayable.id)
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
    var headerUpdated: (() -> ())?

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

    func viewControllers(for reportables: [EventReportable]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        for report in reportables {
            switch report {
            case let report as DefaultDateTimeReport:
                viewControllers.append(DefaultEventDateTimeViewController(viewModel: DefaultDateTimeViewModel(report: report)))
            default:
                break
            }
        }

        return viewControllers
    }
}

class DemoBuilder: EventBuilding {
    func createEvent(for type: EventType) -> (event: Event, displayable: EventListDisplayable) {
        let event = Event()
        let displayable = EventListDisplayable()

        event.add(report: DefaultDateTimeReport(event: event))
        displayable.eventId = event.id

        return (event, displayable)
    }
}

struct DemoEventSubmittable: EventSubmittable {
    var title: String {
        return "Event Submitted"
    }
    var detail: String {
        return "Yay!"
    }
}
