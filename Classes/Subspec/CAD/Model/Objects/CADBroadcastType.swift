//
//  CADBroadcastType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADBroadcastType {

    // MARK: - Network
    var createdAt: Date! { get }
    var details: String! { get }
    var identifier: String! { get }
    var lastUpdated: Date! { get }
    var location : CADLocationType! { get }
    var title: String! { get }

    // MARK: - Generated
    var categoryType: CADBroadcastCategoryType { get }
    var createdAtString: String { get }
}
