//
//  AppDelegate.swift
//  MPOL
//
//  Created by Rod Brown on 13/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import UserNotifications
import MPOLKit
import PromiseKit
import Lottie
import ClientKit
import Alamofire

#if INTERNAL
    import HockeySDK
#endif

private let host = APP_HOST_URL
let TermsAndConditionsVersion = "1.0"
let WhatsNewVersion = "1.0"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var landingPresenter: LandingPresenter!

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        MPOLKitInitialize()

        let refreshTokenPlugin = RefreshTokenPlugin { response -> Promise<Void> in
            self.attemptRefresh(response: response)
        }.withRule(.blacklist((DefaultFilterRules.authenticationFilterRules)))

        var plugins: [Plugin] = [refreshTokenPlugin, NetworkMonitorPlugin().allowAll()]
        #if DEBUG
            plugins.append(NetworkLoggingPlugin().allowAll())
        #endif

        // Set the application key for app specific user settings
        User.applicationKey = "Search"

        landingPresenter = LandingPresenter()
        let presenter = PresenterGroup(presenters: [SystemPresenter(), landingPresenter, EntityPresenter(), EventPresenter()])

        let director = Director(presenter: presenter)
//        director.addPresenterObserver(RecentlyViewedTracker())

        Director.shared = director

        APIManager.shared = APIManager(configuration: APIManagerDefaultConfiguration(url: "https://\(host)", plugins: plugins, trustPolicyManager: ServerTrustPolicyManager(policies: [host: .disableEvaluation])))

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)

        registerPushNotifications(application)

        let window = UIWindow()
        self.window = window
        
        applyCurrentTheme()

        updateAppForUserSession()

        window.makeKeyAndVisible()

        #if INTERNAL
            let manager = BITHockeyManager.shared()
            manager.configure(withIdentifier: "f9141bb9072344a5b316f83f2b2417a4")
            manager.start()

            manager.updateManager.updateSetting = .checkStartup
            manager.crashManager.crashManagerStatus = .autoSend

            let authenticator = manager.authenticator
            authenticator.authenticationSecret = "5de18549749959214aa44495e09faad5"
            authenticator.identificationType = .hockeyAppEmail
            authenticator.authenticateInstallation()
        #endif

        return true
    }

    private func updateAppForUserSession() {

        // Reload user from shared storage if logged in, in case updated by another mpol app
        if UserSession.current.isActive == true {
            UserSession.current.restoreSession { token in
                APIManager.shared.setAuthenticationPlugin(AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token)), rule: .blacklist(DefaultFilterRules.authenticationFilterRules))
            }
        }

        // Update screen if necessary
        landingPresenter.updateInterfaceForUserSession(animated: false)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reload user session and update UI to match current state
        updateAppForUserSession()
    }

    // MARK: - APNS
    
    func registerPushNotifications(_ application: UIApplication) {

        let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if error == nil {
                #if !arch(i386) && !arch(x86_64)
                    DispatchQueue.main.async {
                        // `completionHandler` might be executed in background thread according
                        // to documentation.
                        application.registerForRemoteNotifications()
                    }
                #endif
            }
        }

    }

    // Called to represent what action was selected by the user
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

    }

    // Called when notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }

        // TODO: Upload token to server & register for PNS
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notification: \(error)")
    }
    
    private func attemptRefresh(response: DataResponse<Data>) -> Promise<Void> {

        let promise: Promise<Void>
        
        // Create refresh token request with current token
        if let token = UserSession.current.token?.refreshToken {
            promise = APIManager.shared.accessTokenRequest(for: .refreshToken(token))
                .then { token -> Void in
                    // Update access token
                    APIManager.shared.setAuthenticationPlugin(AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token)), rule: .blacklist(DefaultFilterRules.authenticationFilterRules))
                    UserSession.current.updateToken(token)
                }.recover { error -> Promise<Void> in
                    // Throw 401 error instead of refresh token error
                    throw response.error!
            }
        } else {
            promise = Promise(error: response.error!)
        }
        
        return promise.catch { error in
            UserSession.current.endSession()
            self.landingPresenter.updateInterfaceForUserSession(animated: true)
            AlertQueue.shared.addSimpleAlert(title: "Session Ended", message: error.localizedDescription)
        }
    }

    // TEMP
    func logOut() {
        UserSession.current.endSession()
        APIManager.shared.setAuthenticationPlugin(nil)
        landingPresenter.updateInterfaceForUserSession(animated: false)
    }

    @objc private func interfaceStyleDidChange() {
        applyCurrentTheme()

        if let window = self.window {
            let views = window.subviews
            for view in views {
                view.removeFromSuperview()
            }
            for view in views {
                window.addSubview(view)
            }

            if UIApplication.shared.applicationState != .background {
                UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
    }

    private func applyCurrentTheme() {
        let theme = ThemeManager.shared.theme(for: .current)
        let shadowImage = theme.image(forKey: .navigationBarShadow)

        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(theme.image(forKey: .navigationBarBackground), for: .default)
        navBar.barStyle  = theme.navigationBarStyle
        navBar.tintColor = theme.color(forKey: .navigationBarTint)
        navBar.shadowImage = shadowImage

        let navBarExtension = NavigationBarExtension.appearance()
        navBarExtension.barStyle  = theme.navigationBarStyle
        navBarExtension.backgroundImage = theme.image(forKey: .navigationBarExtension)
        navBarExtension.tintColor = theme.color(forKey: .navigationBarTint)
        navBarExtension.shadowImage = shadowImage

        UITabBar.appearance().barStyle = theme.tabBarStyle

        window?.tintColor = theme.color(forKey: .tint)

        AlertQueue.shared.preferredStatusBarStyle = theme.statusBarStyle
    }
}
