//
//  EventsListViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class EventsListViewController: FormBuilderViewController {

    let viewModel: EventListViewModelType

    required public init(viewModel: EventListViewModelType) {
        self.viewModel = viewModel
        super.init()
        title = "Events"
        tabBarItem.image = AssetManager.shared.image(forKey: .tabBarEvents)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = "No events"
        loadingManager.noContentView.subtitleLabel.text = "There are currently no active or queued events"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconFolder)
        loadingManager.noContentView.actionButton.setTitle("Create new event", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New event", style: .plain, target: self, action: #selector(createNewEvent))

        loadingManager.state = .noContent
    }

    open override func construct(builder: FormBuilder) {
        builder.title = "Events"
    }

    @objc private func createNewEvent() {
        guard let event = viewModel.eventsManager.create(eventType: .blank) else { return }
        let viewController = EventSplitViewController(viewModel: viewModel.detailsViewModel(for: event))

        show(viewController, sender: self)
    }
}

public class DefaultEventsListViewModel: EventListViewModelType {
    public var title: String

    public var eventsList: [EventListDisplayable]?
    public var eventsManager: EventsManager

    public required init(eventsManager: EventsManager = EventsManager.shared) {
        self.eventsManager = eventsManager
        self.title = "Events"
    }

    public func event(for displayable: EventListDisplayable) -> Event {
        return eventsManager.event(for: displayable.eventId)
    }

    public func detailsViewModel(for event: Event) -> EventDetailViewModelType {
        return DefaultEventsDetailViewModel(event: event)
    }
}

