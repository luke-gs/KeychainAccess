//
//  ResourceUnitType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADResourceUnitType: CADEnumType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADResourceUnitType] { get }

    // MARK: - Methods

    /// The display title for the unit type
    var title: String { get }

    /// The icon image representing the unit type
    var icon: UIImage? { get }
}
