//
//  CADBroadcastType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADBroadcastType {
    var identifier: String! { get }
    var title: String! { get }
    var location : CADLocation! { get }
    var lastUpdated: Date! { get }
    var details: String! { get }
    var createdAt: Date! { get }

    var category: CADBroadcastCategoryType { get }
    var createdAtString: String { get }
}
