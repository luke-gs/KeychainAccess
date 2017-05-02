//
//  NetworkMonitor.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public extension NSNotification.Name {
    
    /// Notification posted when network activity begins. This will be called on the main thread.
    static let NetworkActivityDidBegin = NSNotification.Name(rawValue: "MPOLKit_NetworkActivityDidBegin")
    
    /// Notification posted when network activity ends. This will be called on the main thread.
    static let NetworkActivityDidEnd = NSNotification.Name(rawValue: "MPOLKit_NetworkActivityDidEnd")
    
}


/// `NetworkActivityMonitor` is an object wrapper around a global count of active network interactions.
///
/// Actions that start network activity should call the `networkEventDidBegin()` method, and call the 
/// paired `networkEventDidEnd()` method.
///
/// Applications can observe network monitor notifications to toggle on and off their network activity
/// indicator. These notifications will always be called on the main queue.
public final class NetworkMonitor: NSObject {
    
    
    /// The singleton network monitor.
    public static let shared = NetworkMonitor()
    
    
    /// A boolean value indicating whether the network is currently registered as active.
    public var isNetworkActive: Bool {
        return activityCount > 1
    }
    
    /// The count of network actions currently registered for the application.
    ///
    /// - Note: This API is marked as internally visible for testing purposes.
    internal private(set) var activityCount: Int = 0
    
    
    /// The initializer is private. This manintains guaranteed signleton state.
    private override init() {
    }
    
    
    // MARK: - Updating activity
    
    
    /// Call this method to inform the monitor a network event has started. This can be called
    /// from any thread.
    ///
    /// - Important: This should always be paired with a call to `networkEventDidEnd()`
    ///   on completion.
    public func networkEventDidStart() {
        DispatchQueue.main.async {
            self.activityCount += 1
            
            if self.activityCount == 1 {
                NotificationCenter.default.post(name: .NetworkActivityDidBegin, object: self)
            }
        }
    }
    
    
    /// Call this method to inform the monitor a network event has ended. This can be called
    /// from any thread.
    ///
    /// - Important: This should always be called after a paired 'networkEventDidBegin()` call.
    public func networkEventDidEnd() {
        DispatchQueue.main.async {
            self.activityCount -= 1
            
            if self.activityCount == 0 {
                NotificationCenter.default.post(name: .NetworkActivityDidEnd, object: self)
            }
        }
    }
    
}
