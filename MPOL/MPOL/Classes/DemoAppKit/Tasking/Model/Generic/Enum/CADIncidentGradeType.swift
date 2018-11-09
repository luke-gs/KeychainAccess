//
//  IncidentGradeType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
/// Protocol for an enum representing incident grade
public protocol CADIncidentGradeType: CADEnumStringType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADIncidentGradeType] { get }

    // MARK: - Methods

    /// The display title for the grade
    var title: String { get }

    // Return badge text, border and fill color
    var badgeColors: (text: UIColor, border: UIColor, fill: UIColor) { get }
}
