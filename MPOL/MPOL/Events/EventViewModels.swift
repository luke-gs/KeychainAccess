//
//  EventViewModel.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class EventsListViewModel: EventListViewModelType {
    public var title: String

    public var eventsList: [EventListDisplayable]?
    public var eventsManager: EventsManager
    
    public required init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
        self.title = "Events"
    }
    
    public func event(for displayable: EventListDisplayable) -> Event {
        return eventsManager.event(for: displayable.eventId)
    }
    
    public func detailsViewModel(for event: Event) -> EventDetailViewModelType {
        return DefaultEventsDetailViewModel(event: event, builder: EventScreenBuilder())
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
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        readyToSubmit = evaluationState
    }
}
