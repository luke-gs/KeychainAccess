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
            let loginViewController = LoginViewController()

            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1

            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = LoginHeaderView(title: NSLocalizedString("PSCore", comment: "Login screen header title"),
                                                             subtitle: NSLocalizedString("Public Safety Mobile Platform", comment: "Login screen header subtitle"), image: #imageLiteral(resourceName: "MPOLIcon"))

            loginViewController.delegate = self

            #if DEBUG
                loginViewController.usernameField.text = "matt"
                loginViewController.passwordField.text = "vicroads"
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
            let callsignViewController = CompactCallsignViewController()
            callsignViewController.tabBarItem = UITabBarItem(title: "Callsign", image: AssetManager.shared.image(forKey: .entityCar), selectedImage: nil)

            let searchProxyViewController = AppProxyViewController(appUrlTypeScheme: SEARCH_APP_SCHEME)
            searchProxyViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)

            let tasksListContainerViewModel = TasksListContainerViewModel(headerViewModel: TasksListHeaderViewModel(), listViewModel: TasksListViewModel())
            let tasksSplitViewModel = TasksSplitViewModel(listContainerViewModel: tasksListContainerViewModel,
                                                          mapViewModel: TasksMapViewModel(),
                                                          filterViewModel: TaskMapFilterViewModel())
            let tasksNavController = UINavigationController(rootViewController: tasksSplitViewModel.createViewController())
            tasksNavController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)
            tasksNavController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tasks Tab Bar Item")

            // Show settings cog on left side of tasks list
            let masterVC = (tasksNavController.viewControllers.first as? MPOLSplitViewController)?.masterViewController
            masterVC?.navigationItem.leftBarButtonItem = settingsBarButtonItem()

            let activityLogViewModel = ActivityLogViewModel()
            let activityNavController = UINavigationController(rootViewController: activityLogViewModel.createViewController())
            activityNavController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarActivity)
            activityNavController.tabBarItem.title = NSLocalizedString("Activity Log", comment: "Activity Log Tab Bar Item")

            let userCallsignStatusViewModel = UserCallsignStatusViewModel()
            let statusTabBarViewModel = CADStatusTabBarViewModel(userCallsignStatusViewModel: userCallsignStatusViewModel)
            let sessionViewController = statusTabBarViewModel.createViewController()

            sessionViewController.regularViewControllers = [searchProxyViewController, tasksNavController, activityNavController]
            sessionViewController.compactViewControllers = sessionViewController.viewControllers + [callsignViewController]
            sessionViewController.selectedViewController = tasksNavController
            sessionViewController.statusTabBarDelegate = self
            return sessionViewController
        }
    }

    /// Custom login using the CAD API manager
    override open func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        #if DEBUG
            controller.setLoading(true, animated: true)
            CADStateManager.apiManager.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] token -> Void in
                guard let `self` = self else { return }

                APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
                UserSession.startSession(user: User(username: username), token: token)
                controller.resetFields()
                self.updateInterfaceForUserSession(animated: true)

            }.catch { error in
                let error = error as NSError
                let title = error.localizedFailureReason ?? "Error"
                let message = error.localizedDescription
                controller.present(SystemScreen.serverError(title: title, message: message))
            }.always {
                controller.setLoading(false, animated: true)
            }
        #else
            super.loginViewController(controller, didFinishWithUsername: username, password: password)
        #endif
    }

    // MARK: - Private

    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        (UIApplication.shared.delegate as! AppDelegate).logOut()
    }
}

// MARK: - StatusTabBarDelegate
extension LandingPresenter: StatusTabBarDelegate {
    public func controller(_ controller: StatusTabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let appProxy = viewController as? AppProxyViewController {
            appProxy.launchApp()
            return false
        }
        return true
    }
}
