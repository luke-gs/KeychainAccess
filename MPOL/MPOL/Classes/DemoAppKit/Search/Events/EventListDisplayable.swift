//
//  EventListDisplayable.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//
import CoreKit
/// Event Displayable used to map against the OOTB
/// Event List UI
///
/// Used as metadata for an event
/// encoded to/decoded from a database
/// instead of inflating a whole event object
/// just to show in the list
open class EventListDisplayable {

    /// A unique ID of the event
    open var id: String

    /// The creation date of event
    open var creationDate: Date

    /// The icon to display on the left of the cell
    open var iconKey: AssetManager.ImageKey?

    /// The title to display on the left of the cell
    open var title: String?

    /// The subtitle to display on the left of the cell
    open var subtitle: String?

    /// The accessory title to display on the right of the cell
    open var accessoryTitle: String?

    /// The accessory subtitle to display on the right of the cell
    open var accessorySubtitle: String?

    /// The status of the event
    open var status: EventStatus

    public init(id: String,
                creationDate: Date,
                title: String? = nil,
                subtitle: String? = nil,
                accessoryTitle: String? = nil,
                accessorySubtitle: String? = nil,
                iconKey: AssetManager.ImageKey? = nil,
                status: EventStatus = .draft) {
        self.id = id
        self.creationDate = creationDate
        self.title = title
        self.subtitle = subtitle
        self.accessoryTitle = accessoryTitle
        self.accessorySubtitle = accessorySubtitle
        self.status = status
        self.iconKey = iconKey
    }

}

/// The view model definition for the event details for the OOTB product
public protocol EventDetailViewModelType: Evaluatable {

    // The event object
    var event: Event { get }

    /// The title for the details view controller
    var title: String? { get }

    /// The viewcontrollers to be displayed in the detail view for the sections
    var viewControllers: [UIViewController]? { get }

    /// Closure to call when the header gets updated with a new title or subtitle
    var headerUpdated: (() -> Void)? { get set }

    /// The header to display at the top of the sidebar
    ///
    /// `nil` if no header
    ///
    /// The app defines what view to use
    var headerView: UIView? { get }

    /// Initialiser
    ///
    /// - Parameters:
    ///   - event: The event object
    ///   - builder: The screen builder
    init(event: Event, builder: EventScreenBuilding)
}

/// The event status
///
/// - draft: Event is a draft
/// - queued: Event is queued
public enum EventStatus: String, Codable {
    case draft
    case queued
}

/// A protocol defining whether the object should be a
/// event header update delegate
public protocol SideBarHeaderUpdateable {
    var delegate: SideBarHeaderUpdateDelegate? { get set }
}

/// The delegate responsible for updating the sidebar header for events
public protocol SideBarHeaderUpdateDelegate: class {
    func updateHeader(with title: String?, subtitle: String?)
}
