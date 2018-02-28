//
//  CADActivityLogItem.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an activity log item
public protocol CADActivityLogItemType: class {

    // MARK: - Network
    var description: String? { get set }
    var source: String? { get set }
    var timestamp: Date { get set }
    var title: String? { get set }

    // MARK: - Generated
    var color: UIColor { get }
}
