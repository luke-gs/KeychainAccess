//
//  IncidentListDisplayable.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Cache
import Foundation

/// Incident Displayable used to map against the OOTB
/// Incident List UI
open class IncidentListDisplayable: NSSecureCoding {

    /// A unique ID of the incident metadata
    open var id: UUID = UUID()

    /// A unique ID of the incident
    open var incidentId: UUID = UUID()

    /// The icon to display on the left of the cell
    open var icon: ImageWrapper?

    /// The title to display on the left of the cell
    open var title: String?

    /// The subtitle to display on the left of the cell
    open var subtitle: String?

    public init(title: String? = nil,
                subtitle: String? = nil,
                icon: UIImage? = nil)
    {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon != nil ? ImageWrapper(image: icon!) : nil
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

    /// Initialise the viewmodel with an incident manager
    ///
    /// - Parameters:
    ///   - report: the report for the incident view model
    ///   - incidentManager: the incident manager
    init(report: Reportable, incidentsManager: IncidentsManager)

    /// Gets an incident for a particular displayable
    ///
    /// - Parameter displayable: the incident displayable to fetch the incident for
    /// - Returns: the incident object
    func incident(for displayable: IncidentListDisplayable) -> Incident?

    /// Provide the detailViewModel for an event
    ///
    /// - Returns: the detail view model
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

    /// Initialiser
    ///
    /// - Parameters:
    ///   - event: the incident object
    ///   - builder: the screen builder
    init(incident: Incident, builder: IncidentScreenBuilding)
}

