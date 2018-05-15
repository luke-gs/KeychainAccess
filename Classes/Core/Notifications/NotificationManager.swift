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
import KeychainAccess

/// Manager for receiving and sending notifications
open class NotificationManager: NSObject {

    private let PushKeyKeychainKey = "NotificationManager.pushKey"

    public enum NotificationError: Error {
        case userRejected
        case alreadyRejected
    }

    /// Singleton
    open static var shared = NotificationManager()

    /// Convenience for notification center
    open let notificationCenter = UNUserNotificationCenter.current()

    /// Keychain to use when storing sensitive configuration
    open var keychain: Keychain

    /// The handler for processing push notifications
    open var handler: NotificationHandler?

    /// The current Apple issued push token
    open private(set) var pushToken: String?
    
    /// The current AES key for push notification payload decryption
    open private(set) var pushKey: Data! {
        didSet {
            try? keychain.set(pushKey, key: PushKeyKeychainKey)
        }
    }

    // MARK: - Setup
    
    public init(keychain: Keychain = SharedKeychainCapability.defaultKeychain) {
        self.keychain = keychain
        super.init()

        notificationCenter.delegate = self

        // Generate initial push key
        resetPushKey()

        // Observe session changes to update device registration
        NotificationCenter.default.addObserver(self, selector: #selector(userSessionDidStart), name: .userSessionStarted, object: nil)
    }

    @objc private func userSessionDidStart() {
        // User session was started or restored, register device if ready
        registerPushToken()
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
    open func postLocalNotification(withTitle title: String? = nil, body: String, at date: Date? = nil, userInfo: [AnyHashable: AnyObject]? = nil, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title ?? ""
        content.body = body
        if let userInfo = userInfo {
            content.userInfo = userInfo
        }

        var trigger: UNCalendarNotificationTrigger? = nil
        if let date = date {
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    /// Removes a local notification by identifier
    open func removeLocalNotification(_ identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    /// Removes all local notifications
    open func removeAllLocalNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Remote

    /// Reset the current push key, use this method to cycle the key between users
    open func resetPushKey() {
        // Generate a unique key for server to securely communicate to this device over APNS
        pushKey = CryptoUtils.generateKey(for: AESBlockCipher.AES_256)

        // Update device registration if we have an active user session and token
        registerPushToken()
    }

    /// Update current push token and register it if user logged in
    open func updatePushToken(_ deviceToken: Data) {
        // Convert data token to a string
        let token = deviceToken.hexString()
        print("Push token: \(token)")
        pushToken = token

        // Update device registration if we have an active user session and token
        registerPushToken()
    }

    /// Register push token if it has been issued and a user is logged in
    open func registerPushToken() {
        guard let handler = handler, let pushToken = pushToken, UserSession.current.isActive else { return }

        let request = RegisterDeviceRequest()
        request.pushToken = pushToken

        // Set default properties
        request.deviceId = Device.current.deviceUuid
        request.deviceType = "iOS"

        // Send the unique key for our server to securely communicate to this device over APNS
        request.pushKey = pushKey?.base64EncodedString()

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

    /// To be called by app delegate when a silent remote notification is received
    open func didReceiveRemoteNotification(userInfo: [AnyHashable : Any]) -> Promise<UIBackgroundFetchResult> {
        guard let handler = handler else { return Promise<UIBackgroundFetchResult>.value( .noData) }

        print("Received silent push notification: \(LogUtils.string(from: userInfo))")

        // Defer processing to handler
        return handler.handleSilentNotification(userInfo: userInfo)
    }

    // MARK: - Decryption

    /// Decrypt the contents of an encrypted push notification
    open func decryptContentAsData(_ content: String) -> Data? {
        guard let data = Data(base64Encoded: content) else { return nil }
        guard let pushKey = pushKey else { return nil }

        return CryptoUtils.decryptCipher(AESBlockCipher.AES_256, dataWithIV: data, keyData: pushKey)
    }

    /// Decrypt the contents of an encrypted push notification, returning as a dictionary
    open func decryptContentAsDictionary(_ content: String) -> [String: AnyObject]? {
        // Decrypt the content
        if let decryptedData = decryptContentAsData(content) {
            // JSON decode the result
            if let json = try? JSONSerialization.jsonObject(with: decryptedData, options: []) as? [String: AnyObject]  {
                return json
            }
        }
        return nil
    }

}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// Called when a notification is delivered to foreground app
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received push notification: \(LogUtils.string(from: userInfo))")

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
        print("Opened push notification: \(LogUtils.string(from: userInfo))\nResponse: \(response.actionIdentifier)")

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

// MARK: - Data extension

/// Convenience private extension for converting data to hex string
fileprivate extension Data {
    func hexString() -> String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
