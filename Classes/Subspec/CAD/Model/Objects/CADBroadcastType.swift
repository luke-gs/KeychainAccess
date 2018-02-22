//
//  CADBroadcastType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing a broadcast task
public protocol CADBroadcastType: class, CADTaskListItemModelType {

    // MARK: - Network
    var createdAt: Date! { get }
    var details: String! { get }
    var identifier: String! { get }
    var lastUpdated: Date! { get }
    var location : CADLocationType! { get }
    var title: String! { get }
    var type: CADBroadcastCategoryType! { get }

    // MARK: - Generated
    var createdAtString: String { get }
}
