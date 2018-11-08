//
//  IncidentListDisplayable.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Incident Displayable used to map against the OOTB
/// Incident List UI
/// - Warning:
///     Displayable is strongly owned by Incident
open class IncidentListDisplayable: Codable {

    /// A unique ID of the incident metadata
    open var id: String = UUID().uuidString

    /// A unique ID of the incident
    open var incidentId: String = UUID().uuidString

    /// The icon to display on the left of the cell
    open var iconKey: AssetManager.ImageKey?

    /// The title to display on the left of the cell
    open var title: String?

    /// The subtitle to display on the left of the cell
    open var subtitle: String?

    public init(title: String? = nil,
                subtitle: String? = nil,
                iconKey: AssetManager.ImageKey? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.iconKey = iconKey
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case iconKey
        case id
        case incidentId
        case subtitle
        case title
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        iconKey = try container.decodeIfPresent(AssetManager.ImageKey.self, forKey: .iconKey)
        id = try container.decode(String.self, forKey: .id)
        incidentId = try container.decode(String.self, forKey: .incidentId)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iconKey, forKey: CodingKeys.iconKey)
        try container.encode(id, forKey: CodingKeys.id)
        try container.encode(incidentId, forKey: CodingKeys.incidentId)
        try container.encode(subtitle, forKey: CodingKeys.subtitle)
        try container.encode(title, forKey: CodingKeys.title)
    }
}

/// The view model definition for the incident list for the OOTB product
public protocol IncidentListViewModelType {

    /// The title for the event list view controller
    var title: String { get }

    /// The incident displayed in the list
    var incidentList: [IncidentListDisplayable] { get }

    /// The incident manager
    var incidentsManager: IncidentsManager { get }

    /// Initialise the viewModel with an incident manager
    ///
    /// - Parameters:
    ///   - report: The report for the incident view model
    ///   - incidentManager: The incident manager
    init(report: EventReportable, incidentsManager: IncidentsManager)

    /// Gets an incident for a particular displayable
    ///
    /// - Parameter displayable: The incident displayable to fetch the incident for
    /// - Returns: The incident object
    func incident(for displayable: IncidentListDisplayable) -> Incident?

    /// Provide the detailViewModel for an event
    ///
    /// - Returns: The detail view model
    func detailsViewModel(for incident: Incident) -> IncidentDetailViewModelType
}

/// The view model definition for the incident details for the OOTB product
public protocol IncidentDetailViewModelType: Evaluatable {

    // The incident object
    var incident: Incident { get }

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

    /// Completion used to tell the SplitviewController to reload
    /// so that the side bar will be reloaded to use new header
    var headerUpdated: (() -> Void)? { get set }

    /// Initialiser
    ///
    /// - Parameters:
    ///   - event: The incident object
    ///   - builder: The screen builder
    init(incident: Incident, builder: IncidentScreenBuilding)
}
