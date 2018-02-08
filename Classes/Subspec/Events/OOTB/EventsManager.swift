//
//  EventsManager.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 23/1/18.
//

/// Manages the list of events
///
/// Can be used as a singleton as well as an instance if necessary.
final public class EventsManager {

    /// The shared Eventsmanager singleton
    public static var shared: EventsManager = {
        let eventsManager = EventsManager()
        eventsManager.eventBucket = ObjectBucket<Event>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        eventsManager.displayableBucket = ObjectBucket<EventListDisplayable>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        return eventsManager
    }()

    public var eventBucket: ObjectBucket<Event>?
    public var displayableBucket: ObjectBucket<EventListDisplayable>?
    public var eventBuilder: EventBuilding?

    public convenience init(eventBucket: ObjectBucket<Event>,
                            displayableBucket: ObjectBucket<EventListDisplayable>,
                            eventBuilder: EventBuilding)
    {
        self.init()
        self.eventBucket = eventBucket
        self.displayableBucket = displayableBucket
        self.eventBuilder = eventBuilder
    }

    public init() { }

    public func create(eventType: EventType) -> Event? {
        guard let event = eventBuilder?.createEvent(for: eventType) else { return nil }
        displayableBucket?.add(event.displayable)
        eventBucket?.add(event.event)

        return event.event
    }

    //add
    public func add(event: Event) {
        eventBucket?.add(event)
    }

    //remove
    public func remove(event: Event) {
        eventBucket?.remove(event)
    }
    
    public func remove(for id: UUID) {
        eventBucket?.remove(event(for: id))
//        displayableBucket?.remove(<#T##object: EventListDisplayable##EventListDisplayable#>)
    }

    //utility
    public func event(for id: UUID) -> Event {
        //TODO: Attempt to fetch from event bucket
        //eventBucket.object(for: id)
        return Event()
    }
}

