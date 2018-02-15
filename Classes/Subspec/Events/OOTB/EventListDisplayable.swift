//
//  EventListDisplayable.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Cache

/// Event Displayable used to map against the OOTB
/// Event List UI
///
/// Used as metadata for an event
/// encoded to/decoded from a database
/// instead of inflating a whole event object
/// just to show in the list
open class EventListDisplayable: Codable {

    /// A unique ID of the event metadata
    open var id: UUID = UUID()

    /// A unique ID of the event metadata
    open var eventId: UUID = UUID()

    /// The icon to display on the left of the cell
    open var icon: ImageWrapper?

    /// The title to display on the left of the cell
    open var title: String?

    /// The subtitle to display on the left of the cell
    open var subtitle: String?

    /// The accessory title to display on the right of the cell
    open var accessoryTitle: String?

    /// The accessort subtitle to display on the right of the cell
    open var accessorySubtitle: String?

    public init(title: String? = nil,
                subtitle: String? = nil,
                accessoryTitle: String? = nil,
                accessorySubtitle: String? = nil,
                icon: UIImage? = nil)
    {
        self.title = title
        self.subtitle = subtitle
        self.accessoryTitle = accessoryTitle
        self.accessorySubtitle = accessorySubtitle
        self.icon = icon != nil ? ImageWrapper(image: icon!) : nil
    }
}

/// The view model definition for the event list for the OOTB product
public protocol EventListViewModelType {

    /// The title for the event list view controller
    var title: String { get }

    /// The events displayed in the list
    var eventsList: [EventListDisplayable]? { get }

    /// The events manager
    var eventsManager: EventsManager { get }

    /// Initialise the viewmodel with an events manager
    ///
    /// - Parameter eventsManager: the events manager
    init(eventsManager: EventsManager)

    /// Gets an event for a particular displayable
    ///
    /// - Parameter displayable: the event displayable to fetch the event for
    /// - Returns: the inflated event object
    func event(for displayable: EventListDisplayable) -> Event?

    /// Provide the detailViewModel for an event
    ///
    /// - Returns: the detail view model
    func detailsViewModel(for event: Event) -> EventDetailViewModelType

}

/// The view model definition for the event details for the OOTB product
public protocol EventDetailViewModelType: Evaluatable {

    // The event object
    var event: Event { get }

    /// The title for the details view controller
    var title: String? { get }

    /// The viewcontrollers to be displayed in the detail view for the sections
    var viewControllers: [UIViewController]? { get }

    /// The header to display at the top of the sidebar
    ///
    /// `nil` if no header
    ///
    /// The app defines what view to use
    var headerView: UIView? { get }

    /// Initialiser
    ///
    /// - Parameters:
    ///   - event: the event object
    ///   - builder: the screen builder
    init(event: Event, builder: EventScreenBuilding)
}
