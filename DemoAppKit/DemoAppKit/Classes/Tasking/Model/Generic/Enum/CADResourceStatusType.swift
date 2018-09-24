//
//  CADResourceStatusType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an enum representing resource status
public protocol CADResourceStatusType: CADEnumStringType, TaskStatusItem {

    // MARK: - Static

    /// All cases, in order of display
    static var allCases: [CADResourceStatusType] { get }

    /// All cases related to a current incident, in order of display
    static var incidentCases: [CADResourceStatusType] { get }

    /// All cases unrelated to a current incident, in order of display
    static var generalCases: [CADResourceStatusType] { get }

    /// The default case when status is unknown
    static var defaultCase: CADResourceStatusType { get }

    /// The default case when creating a new incident
    static var defaultCreateCase: CADResourceStatusType { get }

    /// The case for a resource in duress
    static var duressCase: CADResourceStatusType { get }

    /// The case for finalising an incident
    static var finaliseCase: CADResourceStatusType { get }

    /// The case for traffic stop
    static var trafficStopCase: CADResourceStatusType { get }

    // MARK: - Properties

    /// Display title for status
    var title: String { get }

    /// Icon image for status
    var icon: UIImage? { get }

    // Icon color and background color for status
    var iconColors: (icon: UIColor, background: UIColor) { get }

    /// Return whether shift can be terminated from current status
    var canTerminate: Bool { get }

    /// Return whether an incident can be created from current status
    var canCreateIncident: Bool { get }

    /// Whether resources of this status are shown on map
    var shownOnMap: Bool { get }

    /// Return the sort order based on status when resources shown in a list
    var listOrder: Int { get }

    // MARK: - Methods

    /// Return whether status change is allowed, and whether a reason needs to be provided
    func canChangeToStatus(newStatus: CADResourceStatusType) -> (allowed: Bool, requiresReason: Bool)

    /// Convenience for checking if changing to non incident status
    func isChangingToGeneralStatus(_ newStatus: CADResourceStatusType) -> Bool

}

extension CADResourceStatusType {
    /// Convenience for checking if this is the duress case
    public var isDuress: Bool {
        return self == CADClientModelTypes.resourceStatus.duressCase
    }
}

