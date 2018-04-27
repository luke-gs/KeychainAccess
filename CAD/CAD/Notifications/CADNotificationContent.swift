//
//  CADNotificationContent.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 27/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Model object for encrypted push notification content
public struct CADNotificationContent: Codable {
    let type: String
    let operation: String?
    let identifier: String?
}
