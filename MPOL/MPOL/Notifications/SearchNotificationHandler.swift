//
//  SearchNotificationHandler.swift
//  MPOL
//
//  Created by Trent Fitzgibbon on 12/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import PromiseKit
import UserNotifications

class SearchNotificationHandler: NotificationHandler {

    /// Handle a notification while app is in the foreground and return the presentation options
    func handleForegroundNotification(_ notification: UNNotification) -> Promise<UNNotificationPresentationOptions> {
        let userInfo = notification.request.content.userInfo

        // Decrypt the content of the message
        if let _: SearchNotificationContent = NotificationManager.shared.decryptUserInfo(userInfo) {
            // TODO: Work out if we should show this message to user
        }

        // Complete with presentation options so notification is still shown in app
        return Promise<UNNotificationPresentationOptions>.value([.alert, .sound])
    }

    /// Handle the action for a notification that a user has interacted with
    func handleNotificationAction(_ action: NotificationAction, notification: UNNotification) -> Promise<Void> {
        let userInfo = notification.request.content.userInfo

        // Decrypt the content of the message
        if let _: SearchNotificationContent = NotificationManager.shared.decryptUserInfo(userInfo) {
            // TODO: process interaction
        }

        return Promise<Void>()
    }

    /// Handle a silent notification (app may be in foreground or background) and return the data fetch result
    func handleSilentNotification(userInfo: [AnyHashable: Any]) -> Promise<UIBackgroundFetchResult> {

        // Initial completed promise
        var promise = Promise<Void>()

        // Decrypt the content of the message
        if let content: SearchNotificationContent = NotificationManager.shared.decryptUserInfo(userInfo) {
            // TODO: process silent notification
            switch content.type {
            case "location":
                // Location polling
                // TODO: chain a promise that fetches the current location and submits to backend
                promise = promise.then { _ in
                    return LocationManager.shared.requestLocation()
                }.done { _ in
                }
            default:
                break
            }
        }

        // Execute promise then complete the notification with a fetch result indicating that we retrieved new data
        return promise.then { _ in
            return Promise<UIBackgroundFetchResult>.value(.newData)
        }
    }

    /// Configure app specific properties of the request to register for push notifications
    func configureNotificationRegistrationRequest(request: RegisterDeviceRequest) {
        // Can override appVersion, deviceId or other default properties here if necessary
        request.sourceApp = "pscore-search"
    }

    /// Allow app specific handling of registration errors
    func handleRegistrationError(_ error: Error) {
        // TODO: show error, retry, something
        print(error.localizedDescription)
    }

}
