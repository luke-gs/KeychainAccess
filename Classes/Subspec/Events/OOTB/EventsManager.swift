//
//  EventsManager.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 23/1/18.
//

/// Manages the list of events
///
/// Can be used as a singleton as well as an instance if necessary.
public class EventsManager {

    /// The shared Eventsmanager singleton
    public static var shared: EventsManager = {
        let eventsManager = EventsManager()
        eventsManager.eventBucket = ObjectBucket<Event>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        eventsManager.displayableBucket = ObjectBucket<EventListDisplayable>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        eventsManager.eventBuilder = DefaultEventBuilder()
        return eventsManager
    }()

    private(set) public var eventBucket: ObjectBucket<Event>?
    private(set) public var displayableBucket: ObjectBucket<EventListDisplayable>?
    private(set) public var eventBuilder: EventBuilding?

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
        guard let event = eventBuilder?.createEvent(for: .blank) else { return nil }
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

    //utility
    public func event(for id: String) -> Event {
        //TODO: Attempt to fetch from event bucket
        //eventBucket.object(for: id)
        return Event()
    }
}

/// Builder for event
public protocol EventBuilding: NSCoding {

    /// Create an event, injecting any reports that you need.
    ///
    /// - Parameter type: the type of event that is being asked to be created.
    /// - Returns: a tuple of an event and it's list view representation
    func createEvent(for type: EventType) -> (event: Event, displayable: EventListDisplayable)
}

//TODO: Make this something else that is extensible by the app
public enum EventType {
    case blank
}


/// OOTB implmenetation of an event builder
///
/// Used by the shared Events Manager
public class DefaultEventBuilder: EventBuilding {

    public func createEvent(for type: EventType) -> (event: Event, displayable: EventListDisplayable) {
        let event = Event()
        event.add(report: DefaultDateAndTimeReport(event: event))
        return (event: event, displayable: EventListDisplayable(title: "Demo",
                                                                  subtitle: "Sub",
                                                                  accessoryTitle: "AccessTitle",
                                                                  accessorySubtitle: "Acces Sub",
                                                                  icon: AssetManager.shared.image(forKey: AssetManager.ImageKey.advancedSearch)))
    }

    init() { }

    public func encode(with aCoder: NSCoder) {

    }

    public required init?(coder aDecoder: NSCoder) {

    }
}

