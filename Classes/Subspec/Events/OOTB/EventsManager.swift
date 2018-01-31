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

/// Screen builder for the event
///
/// Used to provide a viewcontroller for the reportables
///
/// Can be used to provide different view controllers for OOTB reports
/// - ie. DateTimeReport
public protocol EventScreenBuilding: NSCoding {


    /// Constructs an array of view controllers depending on what reportables are passed in
    ///
    /// - Parameter reportables: the array of reports to construct view controllers for
    /// - Returns: an array of viewController constucted for the reports
    func viewControllers(for reportables: [Reportable]) -> [UIViewController]
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

        // Add default reports here
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

/// OOTB implementation of the screen builder
final public class DefaultEventScreenBuilder: EventScreenBuilding {

    public func viewControllers(for reportables: [Reportable]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        for report in reportables {
            if let viewController = viewController(for: report) {
                viewControllers.append(viewController)
            }
        }

        return viewControllers
    }

    private func viewController(for report: Reportable) -> UIViewController? {
        switch report {
        case let report as DefaultDateAndTimeReport:
            return DefaultEventDateTimeViewController(report: report)
        default:
            return nil
        }
    }

    public init() { }

    public func encode(with aCoder: NSCoder) {

    }

    public required init?(coder aDecoder: NSCoder) {

    }
}

