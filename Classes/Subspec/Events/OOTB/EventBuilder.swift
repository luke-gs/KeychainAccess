//
//  EventBuilder.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//


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

