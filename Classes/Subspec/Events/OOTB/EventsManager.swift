//
//  EventsManager.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 23/1/18.
//

/// Manages the list of events
final public class EventsManager {

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

        return event
    }
    
    //add
    private func add(event: Event) {
        eventBucket.add(event)
    }
    
    //remove
    public func remove(event: Event) {
        eventBucket.remove(event)
    }
    
    public func remove(for id: UUID) {
        guard let event = self.event(for: id), let displayable = event.displayable else { return }
        eventBucket.remove(event)
        displayableBucket.remove(displayable)
    }
    
    //utility
    public func event(for id: UUID) -> Event? {
        return eventBucket.objects?.first(where: {$0.id == id})
    }
}

