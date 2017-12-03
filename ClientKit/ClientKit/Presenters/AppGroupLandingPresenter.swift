//
//  AppGroupLandingPresenter.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

import Foundation
import MPOLKit

/// Enum for all initial screens in a standard MPOL app
public enum LandingScreen: Presentable {

    /// Initial login screen
    case login

    /// Terms and conditions screen, presented as form sheet
    case termsAndConditions

    /// What's new paginated screen
    case whatsNew

    /// The "logged in" screen for this application
    case landing
}

/// Presenter for a standard MPOL app that shares the app group settings of the user session
open class AppGroupLandingPresenter: NSObject, Presenter {

    open func updateInterfaceForUserSession(animated: Bool) {
        let screen = screenForUserSession()
        if screen == .termsAndConditions {
            // Switch to login screen if not current, then present modal for terms and conditions
            if let loginViewController = updateInterface(withScreen: .login, animated: false) {
                // Set current screen to terms and conditions, so changes back to plain login can still be detected
                currentScreen = screen
                DispatchQueue.main.async {
                    loginViewController.present(screen)
                }
            }
        } else {
            // Present screen if not current
            updateInterface(withScreen: screen, animated: animated)
        }
    }

    open func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {

        let presentable = presentable as! LandingScreen
        switch presentable {
        case .termsAndConditions:
            from.present(to, animated: true, completion: nil)
        default:
            from.show(to, sender: from)
        }
    }

    open func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is LandingScreen.Type
    }

    // MARK: - Subclass

    open func viewController(forPresentable presentable: Presentable) -> UIViewController {
        MPLRequiresConcreteImplementation()
    }

    open var termsAndConditionsVersion: String {
        MPLRequiresConcreteImplementation()
    }

    open var whatsNewVersion: String {
        MPLRequiresConcreteImplementation()
    }

    open var appWindow: UIWindow {
        MPLRequiresConcreteImplementation()
    }

    // MARK: - Private

    /// The currently displayed screen
    private var currentScreen: LandingScreen?

    /// The currently displayed view controller
    private var currentViewController: UIViewController?

    /// Return what the current screen should be given the user session state
    private func screenForUserSession() -> LandingScreen {
        if let user = UserSession.current.user, UserSession.current.isActive {
            if user.areTermsAndConditionsAccepted(version: termsAndConditionsVersion) {
                if user.whatsNewShownVersion != whatsNewVersion {
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

        currentScreen = screen
        currentViewController = presenter.viewController(forPresentable: screen)
        appWindow.rootViewController = currentViewController
        if animated {
            UIView.transition(with: appWindow, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
        return currentViewController
    }
}


extension AppGroupLandingPresenter: UsernamePasswordDelegate {

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

extension AppGroupLandingPresenter: TermsConditionsViewControllerDelegate {

    public func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
        controller.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }

            if accept {
                UserSession.current.user?.termsAndConditionsVersionAccepted = self.termsAndConditionsVersion
            } else {
                UserSession.current.endSession()
            }
            self.updateInterfaceForUserSession(animated: true)
        }
    }
}

extension AppGroupLandingPresenter: WhatsNewViewControllerDelegate {

    public func whatsNewViewControllerDidAppear(_ whatsNewViewController: WhatsNewViewController) {
        UserSession.current.user?.whatsNewShownVersion = whatsNewVersion
    }

    public func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        self.updateInterfaceForUserSession(animated: true)
    }
}
