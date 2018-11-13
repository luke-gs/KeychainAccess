//
//  IncidentListDisplayable.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import CoreKit

/// Incident Displayable used to map against the OOTB Incident List UI
open class IncidentListDisplayable {

    /// A unique ID of the incident
    open var id: String

    /// The icon to display on the left of the cell
    open var iconKey: AssetManager.ImageKey?

    /// The title to display on the left of the cell
    open var title: String?

    /// The subtitle to display on the left of the cell
    open var subtitle: String?

    public init(id: String,
                title: String? = nil,
                subtitle: String? = nil,
                iconKey: AssetManager.ImageKey? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconKey = iconKey
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
