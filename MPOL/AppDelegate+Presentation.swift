//
//  Appdelegate+Coordinator.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

internal enum ViewState {
    case login
    case tc(controller: LoginViewController)
    case whatsNew
    case landing
}

extension AppDelegate: LoginViewControllerDelegate, TermsConditionsViewControllerDelegate, WhatsNewViewControllerDelegate {

    internal func updateInterface(for state: ViewState, animated: Bool) {
        switch state {
        case .login:
            let loginViewController = LoginViewController()

            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1

            loginViewController.delegate = self
            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = LoginHeaderView(title: "mPol", subtitle: "Mobile Policing Platform", image: #imageLiteral(resourceName: "MPOLIcon"))

            #if DEBUG
                loginViewController.usernameField.text = "matt"
                loginViewController.passwordField.text = "vicroads"
            #endif

            self.window?.rootViewController = loginViewController

        case .tc(let controller):

            // Show T&C if hasn't been accepted by user
            let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!)
            tsAndCsVC.delegate = self

            let navController = PopoverNavigationController(rootViewController: tsAndCsVC)
            navController.modalPresentationStyle = .formSheet
            controller.present(navController, animated: true, completion: { [unowned controller] in
                controller.resetFields()
            })

        case .whatsNew:

            let whatsNewFirstPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New", detail: "Swipe through and discover the new features and updates that have been included in this release. Refer to the release summary for full update notes.")
            let whatsNewSecondPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "RefreshMagnify"), title: "Search", detail: "Search for persons. Search for vehicles.")
            let whatsNewThirdPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "Avatar 1"), title: "Details", detail: "View details for person and vehicle entities.")

            let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage, whatsNewSecondPage, whatsNewThirdPage])
            whatsNewVC.delegate = self
            self.window?.rootViewController = whatsNewVC

        case .landing:

            func settingsBarButtonItem() -> UIBarButtonItem {
                let settingsItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .settings), style: .plain, target: self, action: #selector(settingsButtonItemDidSelect(_:)))
                settingsItem.accessibilityLabel = NSLocalizedString("Settings", comment: "SettingsIconAccessibility")
                return settingsItem
            }

            let viewModel = MPOLSearchViewModel()
            viewModel.recentViewModel.recentlyViewed = UserSession.current.recentlyViewed

            let searchViewController = SearchViewController(viewModel: viewModel)
            searchViewController.set(leftBarButtonItem: settingsBarButtonItem())

            let eventListVC = EventsListViewController()
            eventListVC.navigationItem.leftBarButtonItem = settingsBarButtonItem()

            let searchNavController = UINavigationController(rootViewController: searchViewController)
            let actionListNavController = UINavigationController(rootViewController: ActionListViewController())
            let eventListNavController = UINavigationController(rootViewController: eventListVC)

            let tasksProxyViewController = UIViewController()
            tasksProxyViewController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tab Bar Item title")
            tasksProxyViewController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)
            tasksProxyViewController.tabBarItem.isEnabled = false

            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [searchNavController, actionListNavController, eventListNavController, tasksProxyViewController]

            self.tabBarController = tabBarController
            self.window?.rootViewController = tabBarController
        }

        if animated, let window = self.window {
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        let settingsNavController = PopoverNavigationController(rootViewController: SettingsViewController())
        settingsNavController.modalPresentationStyle = .popover

        if let popoverController = settingsNavController.popoverPresentationController {
            popoverController.barButtonItem = item
        }

        tabBarController?.present(settingsNavController, animated: true)
    }

    // MARK: - Terms and conditions delegate

    func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
        controller.dismiss(animated: true) {  [weak self] in
            if accept {
                let user = UserSession.current.user
                self?.updateInterface(for: user?.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew, animated: true)
                user!.termsAndConditionsVersionAccepted = TermsAndConditionsVersion
            } else {
                UserSession.current.endSession()
            }
        }
    }
    // MARK: - Login view controller delegate

    func loginViewControllerDidAppear(_ controller: LoginViewController) {
        guard UserSession.current.isActive == true else { return }
        self.updateInterface(for: .tc(controller: controller), animated: true)
        controller.setLoading(false, animated: true)
    }

    func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        controller.setLoading(true, animated: true)

        APIManager.shared.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] token -> Void in
            guard let `self` = self else { return }

            UserSession.startSession(user: User(username: username),
                                     token: token) { [weak self, controller] _ in
                                        let user = UserSession.current.user
                                        if user?.termsAndConditionsVersionAccepted == TermsAndConditionsVersion {
                                            self?.updateInterface(for: user?.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew, animated: true)
                                        } else {
                                            self?.updateInterface(for: .tc(controller: controller), animated: true)
                                        }
                                        controller.setLoading(false, animated: true)

            }
            }.catch { error in

                let nsError = error as NSError

                let alertController = UIAlertController(title: nsError.localizedFailureReason ?? "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default))
                AlertQueue.shared.add(alertController)
                controller.setLoading(false, animated: true)
        }
    }
    
    func loginViewController(_ controller: LoginViewController, didTapForgotPasswordButton button: UIButton) {

    }

    //MARK: Whats new delegate

    func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        self.updateInterface(for: .landing, animated: true)
    }

    func whatsNewViewControllerDidAppear(_ whatsNewViewController: WhatsNewViewController) {
        let user = UserSession.current.user
        user!.whatsNewShownVersion = WhatsNewVersion
    }
}
