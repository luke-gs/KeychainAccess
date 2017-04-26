//
//  NetworkMonitor.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public extension NSNotification.Name {
    /// Notification posted when network activity begins
    static let NetworkMonitorActivityDidBegin = NSNotification.Name(rawValue: "NetworkMonitorActivityDidBegin")
    static let NetworkMonitorActivityDidEnd   = NSNotification.Name(rawValue: "NetworkMonitorActivityDidEnd")
}

/// NetworkMonitor is an object wrapper around a global count of active network interactions.
///
/// Actions that start network activity should register the activity, and call the returned
/// completion handler when the action ceases, whether it was successful or not.
///
/// Applications can observe network monitor notifications to toggle on and off their
/// network activity indicator.
public final class NetworkMonitor: NSObject {
    
    /// The singleton network monitor.
    public static let shared = NetworkMonitor()
    
    
    /// A boolean value indicating whether the network is currently registered as active.
    public var isNetworkActive: Bool {
        return networkActivityCount > 0
    }
    
    /// The count of network actions currently registered for the application.
    ///
    /// - Note: This API is marked as internally visible for testing purposes.
    internal private(set) var networkActivityCount: Int = 0
    
    
    /// The initializer is private. This manintains guaranteed signleton state.
    private override init() {}
    
    
    /// Registers network activity. This method may be called from any thread.
    /// - important:    Users must call the returned completion handler exactly once on completion of their work.
    /// - returns:      A completion handler to be called when network activity has ceased.
    ///                 This closure can be called on any thread.
    public func registerNetworkActivity() -> ((Void) -> Void) {
        DispatchQueue.main.async(execute: incrementNetworkActivity)
        
        return { DispatchQueue.main.async(execute: self.decrementNetworkActivity) }
    }
    
    /// This function is private and will only be called on the main thread.
    private func incrementNetworkActivity() {
        networkActivityCount += 1
        if networkActivityCount == 1 {
            NotificationCenter.default.post(name: .NetworkMonitorActivityDidBegin, object: self)
        }
    }
    
    /// This function is private and will only be called on the main thread.
    private func decrementNetworkActivity() {
        networkActivityCount -= 1
        if networkActivityCount == 0 {
            NotificationCenter.default.post(name: .NetworkMonitorActivityDidEnd, object: self)
        }
    }
}
