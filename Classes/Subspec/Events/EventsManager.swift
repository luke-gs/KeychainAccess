//
//  EventsManager.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.

/// Manages the list of events
final public class EventsManager {

    public weak var delegate: EventsManagerDelegate?
    public var eventBucket: ObjectBucket<Event> = ObjectBucket<Event>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)


    public var displayableBucket: ObjectBucket<EventListDisplayable> = ObjectBucket<EventListDisplayable>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    public var eventBuilder: EventBuilding
    
    public required init(eventBuilder: EventBuilding) {
        self.eventBuilder = eventBuilder
    }
    
    public func create(eventType: EventType) -> Event? {
        let eventDisplayableTuple = eventBuilder.createEvent(for: eventType)

        let event = eventDisplayableTuple.event
        let displayable = eventDisplayableTuple.displayable

        event.displayable = displayable

        displayableBucket.add(displayable)
        eventBucket.add(event)
        delegate?.eventsManagerDidUpdateEventBucket(self)

        return event
    }
    
    //add
    private func add(event: Event) {
        eventBucket.add(event)
        delegate?.eventsManagerDidUpdateEventBucket(self)
    }
    
    //remove
    public func remove(event: Event) {
        eventBucket.remove(event)
        delegate?.eventsManagerDidUpdateEventBucket(self)
    }
    
    public func remove(for id: String) {
        guard let event = self.event(for: id), let displayable = event.displayable else { return }
        eventBucket.remove(event)
        displayableBucket.remove(displayable)
        delegate?.eventsManagerDidUpdateEventBucket(self)
    }
    
    //utility
    public func event(for id: String) -> Event? {
        return eventBucket.objects?.first(where: {$0.id == id})
    }
}

public protocol EventsManagerDelegate: class {
    func eventsManagerDidUpdateEventBucket(_ eventsManager: EventsManager)
}
