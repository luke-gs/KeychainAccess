//
//  CADTaskListSourceType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 22/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an enum representing a source of items in the task list
/// eg Incidents, Resources, Patrols, Broadcasts, KALOFs
public protocol CADTaskListSourceType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADTaskListSourceType] { get }

    // MARK: - Raw value

    // Enum init
    init?(rawValue: Int)

    /// Enum raw value
    var rawValue: Int { get }

    // MARK: - Methods

    /// The default title to show
    var title: String { get }

    /// The short title to show in the source bar
    var shortTitle: String { get }

    /// The annotation type to use for displaying items on map
    var annotationType: MKAnnotationView.Type? { get }

}
