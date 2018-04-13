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

/// Manager for receiving and sending notifications
open class NotificationManager: NSObject {
    
    public enum NotificationError: Error {
        case userRejected
        case alreadyRejected
    }

    /// Singleton
    open static let shared = NotificationManager()

    /// The handler for processing push notifications
    open var handler: NotificationHandler?

    /// The current Apple issued push token
    open private(set) var pushToken: String?
    
    /// Convenience for notification center
    open let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Setup
    
    public override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    /// Checks notification authorization status and requests if not authorized
    @discardableResult
    open func requestAuthorizationIfNeeded() -> Promise<Void> {

        let (promise, resolver) = Promise<Void>.pending()
        
        // Get settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // If not authorized
            if settings.authorizationStatus == .notDetermined {
                // Request alerts and sounds
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
                    if success {
                        resolver.fulfill(())
                    } else if let error = error {
                        resolver.reject(error)
                    }
                }
            } else if settings.authorizationStatus == .denied {
                resolver.reject(NotificationError.alreadyRejected)
            } else if settings.authorizationStatus == .authorized {
                resolver.fulfill(())
            }
        }
        
        return promise
    }
    
    // MARK: - Local

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

    // MARK: - Remote

    open func updatePushToken(_ deviceToken: Data) {
        // Convert data token to a string
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("Push token: \(token)")

        // Store token and register if we have an active user session
        pushToken = token
        registerPushToken()
    }

    open func registerPushToken() {
        guard let handler = handler, let pushToken = pushToken, UserSession.current.isActive else { return }

        // Register token if it has been issued and a user is logged in
        let request = RegisterDeviceRequest()
        request.pushToken = pushToken

        // Set default properties
        request.deviceId = Device.current.deviceUuid
        request.deviceType = "iOS"

        #if DEBUG
        request.appVersion = "debug"
        #else
        request.appVersion = "release"
        #endif

        // Configure app specific properties
        handler.configureNotificationRegistrationRequest(request: request)

        // Try to register the device, pass any errors to the app specific handler
        APIManager.shared.registerDevice(with: request).catch { error in
            handler.handleRegistrationError(error)
        }
    }

    open func didReceiveRemoteNotification(userInfo: [AnyHashable : Any]) -> Promise<UIBackgroundFetchResult> {
        guard let handler = handler else { return Promise<UIBackgroundFetchResult>.value( .noData) }

        // Defer processing to handler
        return handler.handleSilentNotification(userInfo: userInfo)
    }

}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// Called when a notification is delivered to foreground app
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received push notification: \(userInfo.asLogString())")

        guard let handler = handler else {
            completionHandler([.alert, .sound])
            return
        }

        // Defer processing and presentation to handler
        _ = handler.handleForegroundNotification(notification).done { options -> Void in
            completionHandler(options)
        }.catch { error -> Void in
            completionHandler([])
        }
    }

    /// Called when the user responded to the notification by opening the application,
    /// dismissing the notification or choosing a UNNotificationAction
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Opened push notification: \(userInfo.asLogString())\nResponse: \(response.actionIdentifier)")

        guard let handler = handler else {
            completionHandler()
            return
        }

        let action: NotificationAction
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            action = .openApp
        case UNNotificationDismissActionIdentifier:
            action = .dismissed
        default:
            action = .customAction(actionIdentifier: response.actionIdentifier)
        }

        // Defer processing to handler
        _ = handler.handleNotificationAction(action, notification: response.notification).ensure {
            completionHandler()
        }
    }

}
