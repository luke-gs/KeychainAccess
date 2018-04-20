//
//  CADIncidentStatusType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an enum representing incident status
public protocol CADIncidentStatusType: CADEnumStringType {

    // MARK: - Static

    /// All cases, in order of display
    static var allCases: [CADIncidentStatusType] { get }

    /// The case for when incident is the current incident
    static var currentCase: CADIncidentStatusType { get }

    // MARK: - Properties

    /// Display title for status
    var title: String { get }

    /// Whether to use dark bakckground when displayed on map
    var useDarkBackgroundOnMap: Bool { get }

    /// Returns whether this status can be used to filter out incidents
    var isFilterable: Bool { get }

}
