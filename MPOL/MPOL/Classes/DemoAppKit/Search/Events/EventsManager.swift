//
//  EventsManager.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
import PublicSafetyKit
/// Manages the list of events
final public class EventsManager {

    public weak var delegate: EventsManagerDelegate?

    /// The builder used to create events and displayables
    public var eventBuilder: EventBuilding

    /// The currently saved local events
    /// TODO: persist and load on startup once events are detangled from rest of event singletons
    public private(set) var events: [Event] = []

    public required init(eventBuilder: EventBuilding) {
        self.eventBuilder = eventBuilder
    }

    public var displayables: [EventListDisplayable] {
        return events.map { event in
            return eventBuilder.displayable(for: event)
        }
    }

    public func create(eventType: EventType) -> Event? {
        let event = eventBuilder.createEvent(for: eventType)

        events.append(event)
        delegate?.eventsManagerDidUpdateEventBucket(self)

        return event
    }

    private func add(event: Event) {
        events.append(event)
        delegate?.eventsManagerDidUpdateEventBucket(self)
    }

    public func remove(for id: String) {
        events.removeAll { event -> Bool in
            return event.id == id
        }
        delegate?.eventsManagerDidUpdateEventBucket(self)
    }

    /// Return the event for a given id
    public func event(for id: String) -> Event? {
        var event: Event? = events.first(where: { $0.id == id })

        #if DEBUG_
        // Open a cloned version of the event, to test serialisation
        if event != nil, let data = try? JSONEncoder().encode(event!) {
            if let copy = try? JSONDecoder().decode(Event.self, from: data) {
                event = copy
            }
        }
        #endif
        return event
    }
}

public protocol EventsManagerDelegate: class {
    func eventsManagerDidUpdateEventBucket(_ eventsManager: EventsManager)
}
