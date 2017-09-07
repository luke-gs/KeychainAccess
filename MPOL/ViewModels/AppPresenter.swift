//
//  File.swift
//  ClientKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit


public enum AppScreen: Presentable {

    case login

    case termsAndConditions

    case whatsNew

    case serverError(title: String, message: String)

    case landing

    case entityDetails(entity: Entity)

    case settings(fromItem: UIBarButtonItem)

    case help(type: EntityType)

    case createEntity(type: EntityType)

    public enum EntityType {
        case person, vehicle, organisation, location
    }

}


public class AppPresenter: NSObject, Presenter {

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! AppScreen

        switch presentable {

        case .login:
            let loginViewController = LoginViewController()

            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1

            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = LoginHeaderView(title: "mPol", subtitle: "Mobile Policing Platform", image: #imageLiteral(resourceName: "MPOLIcon"))

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
            let whatsNewSecondPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "RefreshMagnify"), title: "Search", detail: "Search for persons. Search for vehicles.")
            let whatsNewThirdPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "Avatar 1"), title: "Details", detail: "View details for person and vehicle entities.")

            let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage, whatsNewSecondPage, whatsNewThirdPage])
            whatsNewVC.delegate = self

            return whatsNewVC

        case .landing:
            func settingsBarButtonItem() -> UIBarButtonItem {
                let settingsItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .settings), style: .plain, target: self, action: #selector(settingsButtonItemDidSelect(_:)))
                settingsItem.accessibilityLabel = NSLocalizedString("Settings", comment: "SettingsIconAccessibility")
                return settingsItem
            }

            let searchViewController = SearchViewController(viewModel: MPOLSearchViewModel())
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

            return tabBarController
            
        case .serverError(let title, let message):
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return alertController

        case .settings(let item):
            let settingsNavController = PopoverNavigationController(rootViewController: SettingsViewController())
            settingsNavController.modalPresentationStyle = .popover

            if let popoverController = settingsNavController.popoverPresentationController {
                popoverController.barButtonItem = item
            }
            return settingsNavController

        case .entityDetails(let entity):
            return EntityDetailsSplitViewController(entity: entity)

        case .help(let type):
            let title: String

            switch type {
            case .person:
                title = NSLocalizedString("Person Search Help", comment: "")
            case .vehicle:
                title = NSLocalizedString("Vehicle Search Help", comment: "")
            case .location:
                title = NSLocalizedString("Location Search Help", comment: "")
            case .organisation:
                title = NSLocalizedString("Organisation Search Help", comment: "")
            }

            let helpViewController = UIViewController()
            helpViewController.title = title
            helpViewController.view.backgroundColor = .white
            return helpViewController

        case .createEntity(let type):
            let title: String

            switch type {
            case .person:
                title = NSLocalizedString("New Person", comment: "")
            case .vehicle:
                title = NSLocalizedString("New Vehicle", comment: "")
            case .location:
                title = NSLocalizedString("New Location", comment: "")
            case .organisation:
                title = NSLocalizedString("New Organisation", comment: "")
            }

            let viewController = UIViewController()
            viewController.title = title
            viewController.view.backgroundColor = .white
            return viewController

        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {

        let presentable = presentable as! AppScreen

        switch presentable {
        case .serverError:
            AlertQueue.shared.add(to as! UIAlertController)
        case .termsAndConditions:
            from.present(to, animated: true, completion: nil)
        default:
            from.show(to, sender: from)
        }
    }


    // MARK: - Private

    private weak var tabBarController: UIViewController?

    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        tabBarController?.present(AppScreen.settings(fromItem: item))
    }


    // FIXEME: Tech debt

    func setCurrentUser(withUsername username: String) {
        var user: User?

        let data = UserDefaults.standard.object(forKey: "TemporaryUser") as? Data
        if data != nil {
            user = NSKeyedUnarchiver.unarchiveObject(with: data!) as? User
        }

        if user == nil {
            user = User(username: username)
            self.saveUser(user!)
        }
        AppPresenter.currentUser = user
    }

    static var currentUser: User?

    fileprivate func updateInterface(withScreen screen: AppScreen, animated: Bool) {
        let presenter = Director.shared.presenter

        if animated, let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
            window.rootViewController = presenter.viewController(forPresentable: screen)
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

    func saveUser(_ user: User) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: user), forKey: "TemporaryUser")
        UserDefaults.standard.synchronize()
    }

}


extension AppPresenter: LoginViewControllerDelegate {

    public func loginViewControllerDidAppear(_ controller: LoginViewController) {
        guard UserSession.current.isActive == true else { return }

        let user = UserSession.current.user
        if user?.termsAndConditionsVersionAccepted == TermsAndConditionsVersion {
            let screen: AppScreen = user?.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew
            self.updateInterface(withScreen: screen, animated: true)
        } else {
            controller.present(AppScreen.termsAndConditions)
            controller.resetFields()
        }
    }

    public func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        controller.setLoading(true, animated: true)

        APIManager.shared.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] token -> Void in
            guard let `self` = self else { return }

            APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))

            UserSession.startSession(user: User(username: username), token: token)

            let user = UserSession.current.user
            if user?.termsAndConditionsVersionAccepted == TermsAndConditionsVersion {
                let screen: AppScreen = user?.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew
                self.updateInterface(withScreen: screen, animated: true)
            } else {
                controller.present(AppScreen.termsAndConditions)
                controller.resetFields()
            }
        }.catch { error in
            let error = error as NSError

            let title = error.localizedFailureReason ?? "Error"
            let message = error.localizedDescription

            controller.present(AppScreen.serverError(title: title, message: message))
        }.always {
            controller.setLoading(false, animated: true)
        }
    }

    public func loginViewController(_ controller: LoginViewController, didTapForgotPasswordButton button: UIButton) {

    }

}

extension AppPresenter: TermsConditionsViewControllerDelegate {

    public func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
        controller.dismiss(animated: true) {  [weak self] in
            guard let `self` = self else { return }

            if accept {
                let user = UserSession.current.user!

                user.termsAndConditionsVersionAccepted = TermsAndConditionsVersion

                let screen: AppScreen = user.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew
                self.updateInterface(withScreen: screen, animated: true)
            } else {
                UserSession.current.endSession()
            }
        }
    }

}

extension AppPresenter: WhatsNewViewControllerDelegate {

    public func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        self.updateInterface(withScreen: AppScreen.landing, animated: true)
    }

    public func whatsNewViewControllerDidAppear(_ whatsNewViewController: WhatsNewViewController) {
        let user = UserSession.current.user
        user!.whatsNewShownVersion = WhatsNewVersion
    }

}
