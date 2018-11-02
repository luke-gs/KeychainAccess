//
//  EventListDisplayable.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

/// Event Displayable used to map against the OOTB
/// Event List UI
///
/// Used as metadata for an event
/// encoded to/decoded from a database
/// instead of inflating a whole event object
/// just to show in the list

open class EventListDisplayable: NSSecureCoding {

    /// A unique ID of the event metadata
    open var id: String = UUID().uuidString

    /// A unique ID of the event metadata
    open var eventId: String = UUID().uuidString

    /// The icon to display on the left of the cell
    open var icon: UIImage?

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

    public init(title: String? = nil,
                subtitle: String? = nil,
                accessoryTitle: String? = nil,
                accessorySubtitle: String? = nil,
                icon: UIImage? = nil,
                status: EventStatus = .draft) {
        self.title = title
        self.subtitle = subtitle
        self.accessoryTitle = accessoryTitle
        self.accessorySubtitle = accessorySubtitle
        self.status = status
        self.icon = icon
    }

    //Coding

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case id
        case eventId
        case icon
        case title
        case subtitle
        case accessoryTitle
        case accessorySubtitle
        case status
    }

    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: Coding.id.rawValue)! as String
        eventId = aDecoder.decodeObject(of: NSString.self, forKey: Coding.eventId.rawValue)! as String
        icon = aDecoder.decodeObject(of: UIImage.self, forKey: Coding.icon.rawValue)
        title = aDecoder.decodeObject(of: NSString.self, forKey: Coding.title.rawValue) as String?
        subtitle = aDecoder.decodeObject(of: NSString.self, forKey: Coding.subtitle.rawValue) as String?
        accessoryTitle = aDecoder.decodeObject(of: NSString.self, forKey: Coding.accessoryTitle.rawValue) as String?
        accessorySubtitle = aDecoder.decodeObject(of: NSString.self, forKey: Coding.accessorySubtitle.rawValue) as String?
        status = EventStatus(rawValue: aDecoder.decodeObject(of: NSString.self, forKey: Coding.status.rawValue)! as String)!
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Coding.id.rawValue)
        aCoder.encode(eventId, forKey: Coding.eventId.rawValue)
        aCoder.encode(icon, forKey: Coding.icon.rawValue)
        aCoder.encode(title, forKey: Coding.title.rawValue)
        aCoder.encode(subtitle, forKey: Coding.subtitle.rawValue)
        aCoder.encode(accessoryTitle, forKey: Coding.accessoryTitle.rawValue)
        aCoder.encode(accessorySubtitle, forKey: Coding.accessorySubtitle.rawValue)
        aCoder.encode(status.rawValue, forKey: Coding.status.rawValue)
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
public enum EventStatus: String {
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
