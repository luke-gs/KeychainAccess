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
        // TODO: process notification

        // Complete with presentation options so notification is still shown in app
        return Promise<UNNotificationPresentationOptions>(value: [.alert, .sound])
    }

    /// Handle the action for a notification that a user has interacted with
    func handleNotificationAction(_ action: NotificationAction, notification: UNNotification) -> Promise<Void> {
        // TODO: process interaction

        return Promise<Void>()
    }

    /// Handle a silent notification (app may be in foreground or background) and return the data fetch result
    func handleSilentNotification(userInfo: [AnyHashable : Any]) -> Promise<UIBackgroundFetchResult> {
        // TODO: process notification

        // Complete with fetch result that we retrieved new data
        return Promise<UIBackgroundFetchResult>(value: .newData)
    }

    /// The source app string to use when registering this device for push notifications
    func sourceAppForNotificationRegistration() -> String {
        return "pscore-search"
    }
}
