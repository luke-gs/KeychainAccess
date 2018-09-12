//
//  CADPatrolCategoryType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an enum representing patrol status
public protocol CADPatrolStatusType: CADEnumStringType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADPatrolStatusType] { get }

    /// The default case when status is unknown
    static var defaultCase: CADPatrolStatusType { get }

    // MARK: - Methods

    /// The display title for the category
    var title: String { get }

    /// Whether to use dark bakckground when displayed on map
    var useDarkBackgroundOnMap: Bool { get }
}
