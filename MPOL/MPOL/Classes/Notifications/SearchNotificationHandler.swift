//
//  SearchNotificationHandler.swift
//  MPOL
//
//  Created by Trent Fitzgibbon on 12/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import PromiseKit
import UserNotifications

class SearchNotificationHandler: NotificationHandler {

    /// Handle a notification while app is in the foreground and return the presentation options
    func handleForegroundNotification(_ notification: UNNotification) -> Promise<UNNotificationPresentationOptions> {
        let userInfo = notification.request.content.userInfo

        // Decrypt the content of the message
        if let content: SearchNotificationContent = NotificationManager.shared.decryptUserInfo(userInfo) {
            // TODO: Work out if we should show this message to user

            // Perform sync in background (don't force display of notification to wait)
            switch content.type {
            case "incident":
                _ = CADStateManager.shared.syncDetails()
            default:
                break
            }
        }

        // Complete with presentation options so notification is still shown in app
        return Promise<UNNotificationPresentationOptions>.value([.alert, .sound])
    }

    /// Handle the action for a notification that a user has interacted with
    func handleNotificationAction(_ action: NotificationAction, notification: UNNotification) -> Promise<Void> {
        let userInfo = notification.request.content.userInfo

        // Decrypt the content of the message
        if let content: SearchNotificationContent = NotificationManager.shared.decryptUserInfo(userInfo) {
            // TODO: process interaction

            switch content.type {
            case "incident":
                if let identifier = content.identifier {
                    openIncident(identifier)
                }
            default:
                break
            }
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
                promise = CADStateManager.shared.syncDetails()
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

    // MARK: - Internal

    func taskListPresenter() -> TaskListPresenter? {
        // Find task list presenter
        guard let presenterGroup = Director.shared.presenter as? PresenterGroup else { return nil }
        return presenterGroup.presenters.first { $0 is TaskListPresenter } as? TaskListPresenter
    }

    func openIncident(_ identifier: String) {
        if let viewModel = CADTaskListSourceCore.incident.createItemViewModel(identifier: identifier) {
            if let vc = taskListPresenter()?.tasksSplitViewController {
                if vc.presentedViewController != nil {
                    // Dismiss any existing modal dialog then present
                    vc.dismiss(animated: true, completion: {
                        Director.shared.present(TaskItemScreen.landing(viewModel: viewModel), fromViewController: vc)
                    })
                } else {
                    // Present incident details immediately
                    Director.shared.present(TaskItemScreen.landing(viewModel: viewModel), fromViewController: vc)
                }
            }
        }
    }

}
