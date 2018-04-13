//
//  NotificationHandler.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import UserNotifications
import PromiseKit

/// Protocol for the handler that will actually process incoming notifications
/// Note: To be implemented in client app if using push notifications
public protocol NotificationHandler: class {

    // Note: Normally only a single handleX method will be called on receipt of a push notificaiton. BUT, if a silent
    // notification, "content-available": 1, is sent together with an alert text, both handleSilentNotification and
    // handleForegroundNotification will be called.

    /// Handle a notification while app is in the foreground and return the presentation options
    func handleForegroundNotification(_ notification: UNNotification) -> Promise<UNNotificationPresentationOptions>

    /// Handle the action for a notification that a user has interacted with
    func handleNotificationAction(_ action: NotificationAction, notification: UNNotification) -> Promise<Void>

    /// Handle a silent notification (app may be in foreground or background) and return the data fetch result
    func handleSilentNotification(userInfo: [AnyHashable : Any]) -> Promise<UIBackgroundFetchResult>

    /// Configure app specific properties of the request to register for push notifications
    func configureNotificationRegistrationRequest(request: RegisterDeviceRequest)

    /// Allow app specific handling of registration errors
    func handleRegistrationError(_ error: Error)
}

/// Enum for the action a user made on a notification
public enum NotificationAction {

    // User tapped notification, opening application
    case openApp

    // User dismissed notification (only delivered if category object configured with the customDismissAction option)
    case dismissed

    // User selected a specific custom action on the notification
    case customAction(actionIdentifier: String)
}
