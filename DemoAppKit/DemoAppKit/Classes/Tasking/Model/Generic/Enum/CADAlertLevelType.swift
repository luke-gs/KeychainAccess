//
//  CADAlertLevelType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an enum representing alert level used for associations
public protocol CADAlertLevelType: CADEnumIntType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADAlertLevelType] { get }

    // MARK: - Methods

    /// The display title for the alert level
    var title: String { get }

    /// The color for the alert level
    var color: UIColor? { get }
}
