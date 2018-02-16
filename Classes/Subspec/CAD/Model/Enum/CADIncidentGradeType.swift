//
//  IncidentGradeType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an incident grade enumeration
public protocol CADIncidentGradeType: CADEnumType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADIncidentGradeType] { get }

    // MARK: - Methods

    // Return badge text, border and fill color
    var badgeColors: (text: UIColor, border: UIColor, fill: UIColor) { get }
}
