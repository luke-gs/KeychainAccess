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

    override public var termsAndConditionsVersion: SemanticVersion {
        let version = SemanticVersion(TermsAndConditionsVersion)

        if version == nil {
            assertionFailure("termsAndConditionsVersion is not a valid semanticVersion")
        }
        return version!
    }

    override public var whatsNewVersion: SemanticVersion {
        let version = SemanticVersion(WhatsNewVersion)

        if version == nil {
            assertionFailure("whatsNewVersion is not a valid semanticVersion")
        }
        return version!
    }

    override public var appWindow: UIWindow {
        return (UIApplication.shared.delegate as? AppDelegate)!.window!
    }

    override public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! LandingScreen

        switch presentable {

        case .login:
            let loginViewController = LoginViewController(mode: .credentials(delegate: self))
            loginViewController.setupDefaultStyle(with: nil)

            let loginContainer = LoginContainerViewController()
            loginContainer.setupDefaultStyle()

            loginContainer.addContentViewController(loginViewController)

            return loginContainer
        case .termsAndConditions:
            let acceptAction = DialogAction(title: NSLocalizedString("Accept", bundle: .mpolKit, comment: "T&C - Accept"), handler: didAcceptConditions(_ :))
            let declineAction = DialogAction(title: NSLocalizedString("Decline", bundle: .mpolKit, comment: "T&C - Decline"), handler: didDeclineConditions(_ :))
            let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!, actions: [acceptAction, declineAction])

            let navController = PopoverNavigationController(rootViewController: tsAndCsVC)
            navController.modalPresentationStyle = .pageSheet

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

        let accessibilitySection: SettingSection = SettingSection(type: .plain(title: "Accessibility"), settings: [
            Settings.numericKeyboard,
            Settings.darkMode,
            Settings.biometrics,
            Settings.signature
            ])
        let generalSection: SettingSection = SettingSection(type: .plain(title: "General"), settings: [
            Settings.manifest,
            Settings.support,
            Settings.termsAndConditions,
            Settings.whatsNew
            ])
        let pinnedSection: SettingSection = SettingSection(type: .pinned, settings: [
            Settings.logOut
            ])

        let settingsVC = SettingsViewController(settingSections: [
            accessibilitySection,
            generalSection,
            pinnedSection
            ])

        let settingsNavController = ThemedNavigationController(rootViewController: settingsVC)
        settingsNavController.modalPresentationStyle = .formSheet
        settingsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: settingsVC, action: #selector(UIViewController.dismissAnimated))

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
        let ivData = Data(repeating: 0, count: AESBlockCipher.AES_256.blockSize)
        let encryptedData = CryptoUtils.performCipher(AESBlockCipher.AES_256, operation: .encrypt, data: json, keyData: NotificationManager.shared.pushKey, ivData: ivData)!

        let payloadData = ivData + encryptedData
        let userInfo = [ "content": payloadData.base64EncodedString() ]

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
