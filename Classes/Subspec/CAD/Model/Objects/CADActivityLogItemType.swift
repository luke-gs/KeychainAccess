//
//  CADActivityLogItem.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADActivityLogItemType {
    var title: String! { get }
    var description: String! { get }
    var source: String! { get }
    var timestamp: Date! { get }

    var color: UIColor { get }
}
