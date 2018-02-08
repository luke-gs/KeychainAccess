//
//  NotificationManager.swift
//  MPOLKit
//
//  Created by Kyle May on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import UserNotifications
import PromiseKit

/// Handles receiving and sending notifications
open class NotificationManager: NSObject {
    /// Singleton
    public static let shared = NotificationManager()

    let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Setup
    
    public override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    /// Checks notification authorization status and requests if not authorized
    open func requestAuthorizationIfNeeded() -> Promise<Bool> {
        let (promise, fulfill, _) = Promise<Bool>.pending()
        
        // Get settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // If not authorized
            if settings.authorizationStatus == .notDetermined {
                // Request alerts and sounds
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
                    fulfill(true)
                }
            } else if settings.authorizationStatus == .denied {
                fulfill(false)
            } else if settings.authorizationStatus == .authorized {
                fulfill(true)
            }
        }
        
        return promise
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
        notificationCenter.add(request)
    }
    
    open func removeLocalNotification(_ identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    open func removeAllLocalNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Notification received while app in foreground
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
