//
//  CADBroadcastCategoryType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an enum representing broadcast category type
public protocol CADBroadcastCategoryType: CADEnumStringType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADBroadcastCategoryType] { get }

    /// The default case when status is unknown
    static var defaultCase: CADBroadcastCategoryType { get }

    // MARK: - Methods

    /// The display title for the category
    var title: String { get }

    /// The display title for the category with a given count of items
    func pluralTitle(count: Int) -> String?
}
