//
//  LogOffManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class LogOffManager {
    
    public static var shared: LogOffManager = LogOffManager()
    
    public static let logOffWasRequestedNotification = NSNotification.Name(rawValue: "logOffWasRequested")
    
    open func requestLogOff() {
        NotificationCenter.default.post(name: LogOffManager.logOffWasRequestedNotification, object: nil)
    }
}
