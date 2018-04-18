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
import PromiseKit
import KeychainAccess
import LocalAuthentication

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
open class AppGroupLandingPresenter: NSObject, Presenter, BiometricDelegate {

    public var wantsBiometricAuthentication = true

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

    open func loginViewControllerDidAppear(_ controller: LoginViewController) {

    }

    open func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        authenticateWithUsername(username, password: password, inController: controller)
    }

    open func loginViewController(_ controller: LoginViewController, didTapForgotPasswordButton button: UIButton) {
        // Haha, good luck! Implemented next year maybe.
    }

    open func loginViewControllerDidAuthenticateWithBiometric(_ controller: LoginViewController, context: LAContext) {

        if let handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain) {
            handler.password(context: context).done { [weak self] password -> Void in
                if let password = password {
                    self?.authenticateWithUsername(handler.username, password: password, inController: controller, context: context)
                } else {
                    // Tell the user that they don't have password here, although, if this ever happens,
                    // something probably is broken already.
                    // fatalError for now.
                    fatalError("Biometric authentication isn't setup correctly.")
                }
            }.catch { error in
                let error = error as NSError

                let title = error.localizedFailureReason ?? "Error"
                let message = error.localizedDescription

                controller.present(SystemScreen.serverError(title: title, message: message))
            }
        }

    }

    public func authenticateWithUsername(_ username: String, password: String, inController controller: LoginViewController, context: LAContext? = nil) {
        controller.setLoading(true, animated: true)

        // `lToken` is added so we could start the session slightly later.
        // It's workaround, for now, due to the fact that User data and UserSession are coupled.
        // It causes some data to go out of sync due to the order of loading and saving.
        var lToken: OAuthAccessToken?

        APIManager.shared.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] token -> Promise<Void> in
            guard let `self` = self else {
                throw PMKError.cancelled
            }

            APIManager.shared.setAuthenticationPlugin(AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token)), rule: .blacklist(DefaultFilterRules.authenticationFilterRules))

            lToken = token
            NotificationManager.shared.registerPushToken()
            controller.resetFields()


            // Wants
            if self.wantsBiometricAuthentication {
                let lContext = context ?? LAContext()
                // and can
                if lContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    var biometricUser = BiometricUserHandler(username: username, keychain: SharedKeychainCapability.defaultKeychain)
                    // Ask if the user wants to remember their password.
                    if biometricUser.useBiometric == .unknown {
                        return self.askForBiometricPermission(in: controller).then { promise -> Promise<Void> in
                            // Store the username and password.
                            return biometricUser.setPassword(password, context: context, prompt: NSLocalizedString("AppGroupLandingPresenter.BiometricSavePrompt", comment: "Text prompt to use biometric to save user credentials"))
                            }.done {
                                // Only set it to `agreed` after password saving is successful.
                                biometricUser.useBiometric = .agreed
                                biometricUser.becomeCurrentUser()
                            }.recover(policy: .allErrors) { error -> Promise<Void> in
                                if error.isCancelled {
                                    biometricUser.useBiometric = .asked
                                    return .value(())
                                }
                                throw error
                        }
                    }
                }
            }

            return .value(())

        }.recover(policy: .allErrors) { error -> Promise<Void> in
            if let error = error as? Status {
                // Let the user know something terrible happen, then proceed as usual.
                return self.presentAlertController(in: controller, title: NSLocalizedString("AppGroupLandingPresenter.BiometricSaveCredentialsFailedTitle", comment: "Failed to save credentials using Biometric."), message: error.localizedDescription)
            }
            throw error
        }.done {
            UserSession.startSession(user: User(username: username), token: lToken!)
            self.updateInterfaceForUserSession(animated: true)
        }.then { () -> Promise<Officer> in
            return APIManager.shared.fetchCurrentOfficerDetails(in: MPOLSource.pscore,
                                                                with: CurrentOfficerDetailsFetchRequest())
        }.done { officer in
            try! UserSession.current.userStorage?.add(object: officer,
                                                      key: UserSession.currentOfficerKey,
                                                      flag: UserStorageFlag.session)
        }.ensure {
            controller.setLoading(false, animated: true)
        }.catch { error in
            let error = error as NSError

            let title = error.localizedFailureReason ?? "Error"
            let message = error.localizedDescription

            controller.present(SystemScreen.serverError(title: title, message: message))
        }

    }

    private func askForBiometricPermission(in controller: UIViewController) -> Promise<Void> {
        return Promise { seal in
            let alertController = UIAlertController(title: NSLocalizedString("AppGroupLandingPresenter.BiometricRememberCredentialsTitle", comment: "Title asking whether the user wants to remember credntials using biometric"), message: NSLocalizedString("AppGroupLandingPresenter.BiometricRememberCredentialsMessage", comment: "Message asking whether the user wants to remember credntials using biometric"), preferredStyle: .alert)
            let action = UIAlertAction(title: "Yes", style: .default, handler: { _ in
                seal.fulfill(())
            })
            let cancel = UIAlertAction(title: "No", style: .cancel, handler: { _ in
                seal.reject(PMKError.cancelled)
            })
            alertController.addAction(action)
            alertController.addAction(cancel)
            controller.present(alertController, animated: true)
        }
    }

    private func presentAlertController(in controller: UIViewController, title: String? = nil, message: String? = nil) -> Promise<Void> {
        return Promise { seal in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                seal.fulfill(())
            })
            alertController.addAction(action)
            controller.present(alertController, animated: true)
        }
    }
}

extension AppGroupLandingPresenter: TermsConditionsViewControllerDelegate {

    open func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
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

    open func whatsNewViewControllerDidAppear(_ whatsNewViewController: WhatsNewViewController) {
        UserSession.current.user?.whatsNewShownVersion = whatsNewVersion
    }

    open func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        self.updateInterfaceForUserSession(animated: true)
    }
}
