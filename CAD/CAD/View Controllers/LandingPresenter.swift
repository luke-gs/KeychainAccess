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

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! LandingScreen

        switch presentable {

        case .login:
            let loginViewController = LoginViewController()

            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1

            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = LoginHeaderView(title: NSLocalizedString("Tasks", comment: "Login screen header title"),
                                                             subtitle: NSLocalizedString("Mobile Policing Platform", comment: "Login screen header subtitle"), image: #imageLiteral(resourceName: "MPOLIcon"))

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

    fileprivate func updateInterface(withScreen screen: LandingScreen, animated: Bool) {
        let presenter = Director.shared.presenter

        if animated, let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
            window.rootViewController = presenter.viewController(forPresentable: screen)
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}


extension LandingPresenter: LoginViewControllerDelegate {

    public func loginViewControllerDidAppear(_ controller: LoginViewController) {
        guard UserSession.current.isActive == true else { return }
        guard UserSession.current.user != nil else { return }

        let user = UserSession.current.user
        if user?.termsAndConditionsVersionAccepted == TermsAndConditionsVersion {
            let screen: LandingScreen = user?.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew
            self.updateInterface(withScreen: screen, animated: true)
        } else {
            controller.present(LandingScreen.termsAndConditions)
            controller.resetFields()
        }
    }

    public func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        controller.setLoading(true, animated: true)

        APIManager.shared.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] token -> Void in
            guard let `self` = self else { return }

            APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))

            UserSession.startSession(user: CADUser(username: username), token: token)

            let user = UserSession.current.user
            if user?.termsAndConditionsVersionAccepted == TermsAndConditionsVersion {
                let screen: LandingScreen = user?.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew
                self.updateInterface(withScreen: screen, animated: true)
            } else {
                controller.present(LandingScreen.termsAndConditions)
                controller.resetFields()
            }
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
        controller.dismiss(animated: true) {  [weak self] in
            guard let `self` = self else { return }

            if accept {
                let user = UserSession.current.user!

                user.termsAndConditionsVersionAccepted = TermsAndConditionsVersion

                let screen: LandingScreen = user.whatsNewShownVersion == WhatsNewVersion ? .landing : .whatsNew
                self.updateInterface(withScreen: screen, animated: true)
            } else {
                UserSession.current.endSession()
            }
        }
    }

}

extension LandingPresenter: WhatsNewViewControllerDelegate {

    public func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        self.updateInterface(withScreen: LandingScreen.landing, animated: true)
    }

    public func whatsNewViewControllerDidAppear(_ whatsNewViewController: WhatsNewViewController) {
        let user = UserSession.current.user
        user!.whatsNewShownVersion = WhatsNewVersion
    }

}
