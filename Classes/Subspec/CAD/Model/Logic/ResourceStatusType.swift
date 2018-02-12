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

    /// All enum cases, in order of display
    static var allCases: [ResourceStatusType] { get }

    /// All case related to a current incident, in order of display
    static var incidentCases: [ResourceStatusType] { get }

    /// The default case when status is unknown
    static var defaultCase: ResourceStatusType { get }

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

    /// Return whether status change is allowed, and whether a reason needs to be provided
    func canChangeToStatus(newStatus: ResourceStatusType) -> (allowed: Bool, requiresReason: Bool)

    /// Convenience for checking if changing to non incident status
    func isChangingToGeneralStatus(_ newStatus: ResourceStatusType) -> Bool

}

