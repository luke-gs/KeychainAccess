//
//  LandingPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 20/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class LandingPresenter: AppGroupLandingPresenter {

    var lastSelectedTasks: Date?

    var tasksNavController: UINavigationController!

    override public var termsAndConditionsVersion: String {
        return TermsAndConditionsVersion
    }

    override public var whatsNewVersion: String {
        return WhatsNewVersion
    }

    override public var appWindow: UIWindow {
        return (UIApplication.shared.delegate as? AppDelegate)!.window!
    }

    override public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! LandingScreen

        switch presentable {

        case .login:
            let loginViewController = LoginViewController(mode: .usernamePassword(delegate: self))

            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1

            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = LoginHeaderView(title: NSLocalizedString("PSCore", comment: "Login screen header title"),
                                                             subtitle: NSLocalizedString("Public Safety Mobile Platform", comment: "Login screen header subtitle"), image: #imageLiteral(resourceName: "MPOLIcon"))

            #if DEBUG
                loginViewController.usernameField.textField.text = "gridstone"
                loginViewController.passwordField.textField.text = "mock"
            #endif

            return loginViewController

        case .termsAndConditions:
            let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!)
            tsAndCsVC.delegate = self
            let navController = PopoverNavigationController(rootViewController: tsAndCsVC)
            navController.modalPresentationStyle = .formSheet

            return navController

        case .whatsNew:
            let whatsNewFirstPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New", detail: "Swipe through and discover the new features and updates that have been included in this release. Refer to the release summary for full update notes.")

            let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage])
            whatsNewVC.delegate = self

            return whatsNewVC

        case .landing:
            func settingsBarButtonItem() -> UIBarButtonItem {
                let settingsItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .settings), style: .plain, target: self, action: #selector(settingsButtonItemDidSelect(_:)))
                settingsItem.accessibilityLabel = NSLocalizedString("Settings", comment: "SettingsIconAccessibility")
                return settingsItem
            }
            let callsignViewController = CompactCallsignContainerViewController()
            callsignViewController.tabBarItem = UITabBarItem(title: "Call Sign", image: AssetManager.shared.image(forKey: .entityCar), selectedImage: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(bookOnChanged), name: .CADBookOnChanged, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(callsignChanged), name: .CADCallsignChanged, object: nil)

            let searchProxyViewController = AppProxyViewController(appURLScheme: SEARCH_APP_SCHEME)
            searchProxyViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)

            tasksNavController = UINavigationController(rootViewController: Director.shared.viewController(forPresentable: TaskListScreen.landing))
            tasksNavController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)
            tasksNavController.tabBarItem.selectedImage = AssetManager.shared.image(forKey: .tabBarTasksSelected)
            tasksNavController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tasks Tab Bar Item")

            // Show settings cog on left side of tasks list
            let masterVC = (tasksNavController.viewControllers.first as? MPOLSplitViewController)?.masterViewController
            masterVC?.navigationItem.leftBarButtonItem = settingsBarButtonItem()

            let activityLogViewModel = ActivityLogViewModel()
            let activityNavController = UINavigationController(rootViewController: activityLogViewModel.createViewController())
            activityNavController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarActivity)
            activityNavController.tabBarItem.selectedImage = AssetManager.shared.image(forKey: .tabBarActivitySelected)
            activityNavController.tabBarItem.title = NSLocalizedString("Activity Log", comment: "Activity Log Tab Bar Item")

            let userCallsignStatusViewModel = UserCallsignStatusViewModel()
            let statusTabBarViewModel = CADStatusTabBarViewModel(userCallsignStatusViewModel: userCallsignStatusViewModel)
            let sessionViewController = statusTabBarViewModel.createViewController()

            sessionViewController.regularViewControllers = [searchProxyViewController, tasksNavController, activityNavController]
            sessionViewController.compactViewControllers = sessionViewController.viewControllers + [callsignViewController]
            sessionViewController.selectedViewController = tasksNavController
            sessionViewController.statusTabBarDelegate = self

            self.tabBarController = sessionViewController

            return sessionViewController
        }
    }

    public var wantsForgotPassword: Bool {
        return false
    }

    // MARK: - Private

    private weak var tabBarController: CADStatusTabBarController!

    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        let settingsNavController = PopoverNavigationController(rootViewController: SettingsViewController())
        settingsNavController.modalPresentationStyle = .popover

        if let popoverController = settingsNavController.popoverPresentationController {
            popoverController.barButtonItem = item
        }

        tabBarController.show(settingsNavController, sender: self)
    }

    @objc open func bookOnChanged() {
        // When booked on changes, switch to tasks tab
        if tabBarController.selectedViewController != tasksNavController {
            tabBarController.selectedViewController = tasksNavController
        }

        // Update callsign item
        callsignChanged()
    }

    @objc open func callsignChanged() {
        // Update the tab bar item to show resource info if booked on
        if let tabBarItem = tabBarController.compactViewControllers?.last?.tabBarItem {
            if let resource = CADStateManager.shared.currentResource {
                tabBarItem.title = resource.callsign
                tabBarItem.image = resource.status.icon
            } else {
                tabBarItem.title = NSLocalizedString("Call Sign", comment: "")
                tabBarItem.image = AssetManager.shared.image(forKey: .entityCar)
            }
            tabBarItem.selectedImage = tabBarItem.image
        }
    }

    open func createDummyLocalNotification() {
        guard let incident = CADStateManager.shared.incidents.first(where: {
            return $0.grade == CADIncidentGradeCore.p2
        }) else { return }

        let title = [incident.type, incident.incidentNumber].joined(separator: ": ")
        let message = "Incident has been updated"
        let trigger = Date().adding(seconds: 5)
        let identifier = "Demo"

        // Create encrypted content for notification
        let content = CADNotificationContent(type: "incident", operation: "updated", identifier: incident.incidentNumber)
        let json = try! JSONEncoder().encode(content)
        let encryptedContent = CryptoUtils.performCipher(AESBlockCipher.AES_256, operation: .encrypt, data: json, keyData: NotificationManager.shared.pushKey)!.base64EncodedString()
        let userInfo = [ "content": encryptedContent ]

        NotificationManager.shared.postLocalNotification(withTitle: title,
                                                         body: message,
                                                         at: trigger,
                                                         userInfo: userInfo as [String : AnyObject],
                                                         identifier: identifier)
    }
}

// MARK: - StatusTabBarDelegate
extension LandingPresenter: StatusTabBarDelegate {
    public func controller(_ controller: StatusTabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let appProxy = viewController as? AppProxyViewController {
            appProxy.launch(AppLaunchActivity.open)
            return false
        }

        // TODO: Remove. Hack for demo
        if viewController == tasksNavController {
            if let lastTime = lastSelectedTasks, Date().timeIntervalSince(lastTime) < 0.5 {
                createDummyLocalNotification()
            }
            lastSelectedTasks = Date()
        }
        return true
    }
}
