//
//  EventsManager.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 23/1/18.
//

/// Manages the list of events
final public class EventsManager {

    public var eventBucket: ObjectBucket<Event>?
    public var displayableBucket: ObjectBucket<EventListDisplayable>?
    public var eventBuilder: EventBuilding?
    
    public required init(eventBucket: ObjectBucket<Event>,
                         displayableBucket: ObjectBucket<EventListDisplayable>,
                         eventBuilder: EventBuilding)
    {
        self.eventBucket = eventBucket
        self.displayableBucket = displayableBucket
        self.eventBuilder = eventBuilder
    }
    
    public func create(eventType: EventType) -> Event? {
        guard let event = eventBuilder?.createEvent(for: eventType) else { return nil }
        displayableBucket?.add(event.displayable)
        eventBucket?.add(event.event)

        return event.event
    }
    
    //add
    private func add(event: Event) {
        eventBucket?.add(event)
    }
    
    //remove
    public func remove(event: Event) {
        eventBucket?.remove(event)
    }
    
    public func remove(for id: UUID) {
        guard let event = event(for: id) else {
            return
        }
        eventBucket?.remove(event)
        if let displayable = displayableBucket?.objects?.first(where: {$0.eventId == id}) {
            displayableBucket?.remove(displayable)
        }
    }
    
    //utility
    public func event(for id: UUID) -> Event? {
        return eventBucket?.objects?.first(where: {$0.id == id})
    }
}

