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

public enum LandingScreen: Presentable {

    case login

    case termsAndConditions

    case whatsNew

    case landing

}


public class LandingPresenter: NSObject, Presenter {

    public func updateInterfaceForUserSession(animated: Bool) {
        let screen = screenForUserSession()
        if screen == .termsAndConditions {
            // Present modal dialog for terms and conditions unlike other screens
            if let loginVC = updateInterface(withScreen: .login, animated: false) {
                DispatchQueue.main.async {
                    loginVC.present(screen)
                }
            }
        } else {
            // Present screen if not current
            updateInterface(withScreen: screen, animated: animated)
        }
    }

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
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

            let searchProxyViewController = UIViewController() // TODO: Take me back to the search app
            searchProxyViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
            searchProxyViewController.tabBarItem.isEnabled = false

            let tasksListContainerViewModel = TasksListContainerViewModel(headerViewModel: TasksListHeaderViewModel(), listViewModel: TasksListViewModel())
            let tasksSplitViewModel = TasksSplitViewModel(listContainerViewModel: tasksListContainerViewModel,
                                                          mapViewModel: TasksMapViewModel())
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
            return sessionViewController
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {

        let presentable = presentable as! LandingScreen

        switch presentable {
        case .termsAndConditions:
            from.present(to, animated: true, completion: nil)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is LandingScreen.Type
    }

    // MARK: - Private

    /// The currently displayed screen
    private var currentScreen: LandingScreen?

    /// The currently displayed view controller
    private var currentViewController: UIViewController?

    /// Return what the current screen should be given the user session state
    private func screenForUserSession() -> LandingScreen {
        if let user = UserSession.current.user, UserSession.current.isActive {
            if user.areTermsAndConditionsAccepted(version: TermsAndConditionsVersion) {
                if user.whatsNewShownVersion != WhatsNewVersion {
                    return .whatsNew
                } else {
                    return .landing
                }
            } else {
                return .termsAndConditions
            }
        }
        return .login
    }

    @discardableResult fileprivate func updateInterface(withScreen screen: LandingScreen, animated: Bool) -> UIViewController? {
        let presenter = Director.shared.presenter

        // Only update interface if screen has changed
        if let currentScreen = currentScreen, currentScreen == screen {
            return currentViewController
        }

        if let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
            currentScreen = screen
            currentViewController = presenter.viewController(forPresentable: screen)
            window.rootViewController = currentViewController
            if animated {
                UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
            return currentViewController
        }
        return nil
    }

    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        // DEBUG
        // UserSession.current.user?.appSettings = [:]
        (UIApplication.shared.delegate as! AppDelegate).logOut()
    }
}


extension LandingPresenter: LoginViewControllerDelegate {

    public func loginViewControllerDidAppear(_ controller: LoginViewController) {
    }

    public func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        controller.setLoading(true, animated: true)

        APIManager.shared.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] token -> Void in
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
    }

    public func loginViewController(_ controller: LoginViewController, didTapForgotPasswordButton button: UIButton) {
    }
}

extension LandingPresenter: TermsConditionsViewControllerDelegate {

    public func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
        controller.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }

            if accept {
                UserSession.current.user?.termsAndConditionsVersionAccepted = TermsAndConditionsVersion
            } else {
                UserSession.current.endSession()
            }
            self.updateInterfaceForUserSession(animated: true)
        }
    }
}

extension LandingPresenter: WhatsNewViewControllerDelegate {

    public func whatsNewViewControllerDidAppear(_ whatsNewViewController: WhatsNewViewController) {
        UserSession.current.user?.whatsNewShownVersion = WhatsNewVersion
    }

    public func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        self.updateInterfaceForUserSession(animated: true)
    }
}
