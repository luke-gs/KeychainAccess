//
//  SearchNotificationContent.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Model object for encrypted push notification content used in Search
public struct SearchNotificationContent: Codable {
    let type: String
    let operation: String
    let identifier: String?
}
