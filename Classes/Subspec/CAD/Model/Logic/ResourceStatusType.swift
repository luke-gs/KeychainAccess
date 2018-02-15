//
//  ResourceStatusType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a resource status enum containing customisation and logic per client
public protocol ResourceStatusType {

    // Expose enum init
    init?(rawValue: String)

    // MARK: - Static

    /// All cases, in order of display
    static var allCases: [ResourceStatusType] { get }

    /// All cases related to a current incident, in order of display
    static var incidentCases: [ResourceStatusType] { get }

    /// All cases unrelated to a current incident, in order of display
    static var generalCases: [ResourceStatusType] { get }

    /// The default case when status is unknown
    static var defaultCase: ResourceStatusType { get }

    /// The case for a resource in duress
    static var duressCase: ResourceStatusType { get }

    /// The case for an off duty resource
    static var offDutyCase: ResourceStatusType { get }

    /// The case for an on air resource
    static var onAirCase: ResourceStatusType { get }

    /// The case for finalising an incident
    static var finaliseCase: ResourceStatusType { get }

    // MARK: - Properties

    /// The enum raw value
    var rawValue: String { get }

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

    // MARK: - Methods

    /// Return whether status change is allowed, and whether a reason needs to be provided
    func canChangeToStatus(newStatus: ResourceStatusType) -> (allowed: Bool, requiresReason: Bool)

    /// Convenience for checking if changing to non incident status
    func isChangingToGeneralStatus(_ newStatus: ResourceStatusType) -> Bool

}

extension ResourceStatusType {
    /// Convenience for checking if this is the duress case
    var isDuress: Bool {
        return self == ClientModelTypes.resourceStatus.duressCase
    }
}

/// Equality check without conforming to Equatable, to prevent need for type erasure
func ==(lhs: ResourceStatusType?, rhs: ResourceStatusType?) -> Bool {
    return lhs?.rawValue == rhs?.rawValue
}

/// Inquality check (required when not using Equatable)
func !=(lhs: ResourceStatusType?, rhs: ResourceStatusType?) -> Bool {
    return !(lhs?.rawValue == rhs?.rawValue)
}
