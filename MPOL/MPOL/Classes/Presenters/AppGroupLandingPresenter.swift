//
//  AppGroupLandingPresenter.swift
//  MPOL
//
//  Created by Trent Fitzgibbon on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

import Foundation
import PublicSafetyKit
import PromiseKit
import KeychainAccess
import LocalAuthentication

/// Enum for all initial screens in a standard MPOL app
public enum LandingScreen: Presentable, Equatable {

    /// Initial login screen
    case login

    /// Terms and conditions screen, presented as form sheet
    case termsAndConditions

    /// Biometrics warning screen
    case biometrics(type: LABiometryType)

    /// What's new paginated screen
    case whatsNew

    /// The "logged in" screen for this application
    case landing
}

/// Presenter for a standard MPOL app that shares the app group settings of the user session
open class AppGroupLandingPresenter: NSObject, Presenter, BiometricDelegate {

    public var wantsBiometricAuthentication = true

    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(logOff), name: LogOffManager.logOffWasRequestedNotification, object: nil)
    }

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

    open var appVersion: SemanticVersion {

        //TODO: use bundle version number once version is set up
        let bundleBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let version = SemanticVersion(bundleBuild)

        if version == nil {
            assertionFailure("appVersion is not a valid semanticVersion")
        }
        return version!
    }

    open var termsAndConditionsVersion: SemanticVersion {
        MPLRequiresConcreteImplementation()
    }

    open var whatsNewVersion: SemanticVersion {
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

            let usedVersion = SemanticVersion(user.highestUsedAppVersion)
            if usedVersion == nil || usedVersion! < appVersion {
                user.highestUsedAppVersion = appVersion.rawVersion
                user.lastWhatsNewShownVersion = "0"
                user.lastTermsAndConditionsVersionAccepted = "0"
            }

            if let acceptedVersion = SemanticVersion(user.lastTermsAndConditionsVersionAccepted), acceptedVersion >= termsAndConditionsVersion {

                if let biometrics = biometricsScreen() {
                    return biometrics
                } else {
                    if let shownVersion = SemanticVersion(user.lastWhatsNewShownVersion), shownVersion >= whatsNewVersion {
                        return .landing
                    } else {
                        return .whatsNew
                    }
                }
            } else {
                return .termsAndConditions
            }
        }
        return .login
    }

    private func biometricsScreen() -> LandingScreen? {

        // check that current device supports biometrics
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return nil }
        let type = context.biometryType
        guard type != .none else { return nil }

        // check that we haven't previously asked for biometrics
        guard let handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain),
            handler.useBiometric == .unknown else { return nil }

        return .biometrics(type: type)
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

    // MARK: LoginViewController delegate

    open func loginViewController(_ controller: LoginViewController, didFinishWithCredentials credentials: [LoginCredential]) {
        let usernameCred = credentials.filter {$0.name == "Username"}.first
        let passwordCred = credentials.filter {$0.name == "Password"}.last
        guard let username = usernameCred?.inputField.textField.text,
            let password = passwordCred?.inputField.textField.text else { return }
        authenticateWithUsername(username, password: password, inController: controller)
    }

    open func loginViewControllerDidAuthenticateWithBiometric(_ controller: LoginViewController, context: LAContext) {

        if let handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain) {
            handler.password(context: context).done { [weak self] password -> Void in
                if let password = password {
                    self?.authenticateWithUsername(handler.username, password: password, inController: controller, context: context)
                } else {
                    // BiometricUserHandler won't return password when the biometric set has changed.
                    // Should probably prevent ever getting to here.
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

    open func biometricAuthenticationPrompt(for loginViewController: LoginViewController) -> String {
        if let handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain) {
            return String(format: NSLocalizedString("Login to account %@", comment: ""), handler.username)
        }
        // Shouldn't get here in the first place, something is incorrect.
        fatalError("Biometric authentication isn't setup correctly.")
    }

    open func loginViewController(_ loginViewController: LoginViewController, shouldPromptForEvent event: BiometricPromptEvent) -> Bool {
        // Shouldn't automatically prompt for biometric
        return false
    }

    open func loginViewController(_ loginViewController: LoginViewController, canUseBiometricWithPolicyDomainState policyDomainState: Data?) -> Bool {
        if var handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain) {
            if handler.isEvaluatedPolicyDomainStateStillValid(policyDomainState) {
                return true
            } else {
                handler.clear()
                AlertQueue.shared.addSimpleAlert(title: NSLocalizedString("Biometric data changed", comment: ""), message: NSLocalizedString("The registered biometric has changed since registration. Please login with your credentials", comment: ""))
                return false
            }
        }
        return false
    }

    open func authenticateWithUsername(_ username: String, password: String, inController controller: LoginViewController, context: LAContext? = nil) {
        controller.setLoading(true, animated: true)

        // `lToken` is added so we could start the session slightly later.
        // It's workaround, for now, due to the fact that User data and UserSession are coupled.
        // It causes some data to go out of sync due to the order of loading and saving.
        var lToken: OAuthAccessToken?

        UserSession.prepareForSession()

        APIManager.shared.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] token -> Promise<Void> in
            guard let `self` = self else {
                throw PMKError.cancelled
            }

            let plugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
            APIManager.shared.setAuthenticationPlugin(plugin, rule: .blacklist(DefaultFilterRules.authenticationFilterRules))

            lToken = token
            controller.resetFields()

            // Wants
            if self.wantsBiometricAuthentication {
                let lContext = context ?? LAContext()
                // and can
                if lContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    var biometricUser = BiometricUserHandler(username: username, keychain: SharedKeychainCapability.defaultKeychain)
                    // Ask if the user wants to remember their password.
                    if biometricUser.useBiometric == .unknown {
                        return biometricUser.setPassword(password, context: context, prompt: NSLocalizedString("AppGroupLandingPresenter.BiometricSavePrompt", comment: "Text prompt to use biometric to save user credentials")).done {
                            biometricUser.becomeCurrentUser()
                        }
                        .recover(policy: .allErrors) { error -> Promise<Void> in
                            return .value(())
                        }
                    }
                }
            }

            return .value(())

        }.recover(policy: .allErrors) { error -> Promise<Void> in
            UserSession.current.endSession()

            if let error = error as? Status {
                // Let the user know something terrible happen, then proceed as usual.
                return self.presentAlertController(in: controller, title: NSLocalizedString("AppGroupLandingPresenter.BiometricSaveCredentialsFailedTitle", comment: "Failed to save credentials using Biometric."), message: error.localizedDescription)
            }
            throw error
        }.done {
            UserSession.startSession(user: User(username: username), token: lToken!)
        }.then { [unowned self] () -> Promise<Void> in
            return self.postAuthenticateChain()
        }.ensure {
            controller.setLoading(false, animated: true)
            self.updateInterfaceForUserSession(animated: true)
        }.catch { error in
            let error = error as NSError

            let title = error.localizedFailureReason ?? "Error"
            let message = error.localizedDescription

            controller.present(SystemScreen.serverError(title: title, message: message))
        }

    }

    // MARK: - Log off

    @objc open func logOff() {

        // If we have no token we dont need to revoke it
        guard let refreshToken = UserSession.current.token?.refreshToken else {
            onRemoteLogOffCompleted()
            return
        }

        // To stop users getting stuck unable to logoff when the request fails
        // we invoke the completion regardless of result.
        _ = APIManager.shared.revokeRefreshToken(refreshToken).ensure(onRemoteLogOffCompleted)
    }

    /// Called upon completion of the log out async request, or called immediately if
    /// the refresh token is nil
    open func onRemoteLogOffCompleted() {
        UserSession.current.endSession()
        APIManager.shared.setAuthenticationPlugin(nil)
        self.updateInterfaceForUserSession(animated: false)
    }

    /// Custom post authentication logic that must be executed as part of authentication chain
    /// Eg Search uses this to fetch officer details
    /// By default fetch the clientkit user preferences
    open func postAuthenticateChain() -> Promise<Void> {
        return UserPreferenceManager.shared.fetchSharedUserPreferences()
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

    open func didAcceptConditions(_ dialogAction: DialogAction) {

        currentViewController?.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }

            UserSession.current.user?.lastTermsAndConditionsVersionAccepted = self.termsAndConditionsVersion.rawVersion
            self.updateInterfaceForUserSession(animated: true)
        }
    }

    open func didDeclineConditions(_ dialogAction: DialogAction) {

        currentViewController?.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }

            UserSession.current.endSession()
            self.updateInterfaceForUserSession(animated: true)
        }
    }

    open func didEnableBiometrics() {

        if let handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain) {
            handler.password().done { password in
                if password != nil {
                    UserSession.current.user?.setAppSettingValue(UseBiometric.agreed.rawValue, forKey: .useBiometric)
                    self.updateInterfaceForUserSession(animated: true)
                } else {
                    self.didNotEnableBiometrics()
                }
            }.recover { _ in
                // if biometric has been disabled on system level due to failed attempts, remove biometric button
                let context = LAContext()
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) == false {

                    let typeText = context.biometryType == .faceID ? "Face ID" : "Touch ID"
                    AlertQueue.shared.addSimpleAlert(title: String.localizedStringWithFormat(NSLocalizedString("%@ login attempts exceeded", comment: ""), typeText),
                                                     message: String.localizedStringWithFormat(NSLocalizedString("To enable %@ login, go to settings after you have logged in", comment: ""), typeText),
                                                     handler: { _ in
                                                        self.didNotEnableBiometrics()
                                                     })
                }
            }
        }
    }

    open func didNotEnableBiometrics() {

        // clear password from keychain
        if var handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain) {
            handler.clear()
        }
        UserSession.current.user?.setAppSettingValue(UseBiometric.asked.rawValue, forKey: .useBiometric)
        self.updateInterfaceForUserSession(animated: true)
    }

}

extension AppGroupLandingPresenter: WhatsNewViewControllerDelegate {

    open func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        UserSession.current.user?.lastWhatsNewShownVersion = whatsNewVersion.rawVersion
        self.updateInterfaceForUserSession(animated: true)
    }
}
