//
//  CADNotificationManager.swift
//  MPOLKit
//
//  Created by Kyle May on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import UserNotifications

/// Manages notifications for CAD
open class CADNotificationManager: NSObject {
    /// Singleton
    public static let shared = CADNotificationManager()

    let notificationCenter = UNUserNotificationCenter.current()

    public struct Identifiers {
        public static let shiftEnding = "CADShiftEndingNotification"
    }
    
    // MARK: - Setup
    
    public override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    /// Checks notification authorization status and requests if not authorized
    open func requestAuthorizationIfNeeded(completionHandler: ((_: Bool) -> Void)? = nil) {
        // Get settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // If not authorized
            if settings.authorizationStatus == .notDetermined {
                // Request alerts and sounds
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
                    completionHandler?(success)
                }
            } else if settings.authorizationStatus == .denied {
                completionHandler?(false)
            } else if settings.authorizationStatus == .authorized {
                completionHandler?(true)
            }
        }
    }
    
    /// Posts a local notification
    open func postLocalNotification(withTitle title: String? = nil, body: String, at date: Date? = nil, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title ?? ""
        content.body = body
        
        var trigger: UNCalendarNotificationTrigger? = nil
        if let date = date {
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to add notification with error: \(error.localizedDescription)")
            } else {
                print("Added notification with identifier \(identifier)")
            }
        }
    }
    
    open func removeLocalNotification(_ identifier: String) {
        print("Removing notification with identifier \(identifier)")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    open func removeAllLocalNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension CADNotificationManager: UNUserNotificationCenterDelegate {
    
    // Notification received while app in foreground
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
