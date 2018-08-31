//
//  AppDelegate.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Trent Fitzgibbon. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit
import ClientKit
import CoreLocation
import Alamofire
import PromiseKit

#if !DEBUG
import HockeySDK
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var landingPresenter: LandingPresenter!

    // FIXME: Temporary
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        MPOLKitInitialize()

        let refreshTokenPlugin = RefreshTokenPlugin { response -> Promise<Void> in
            self.attemptRefresh(response: response)
            }.withRule(.blacklist((DefaultFilterRules.authenticationFilterRules)))

        var plugins: [Plugin] = [refreshTokenPlugin, NetworkMonitorPlugin().allowAll(), SessionPlugin().allowAll(), GeolocationPlugin().allowAll()]

        #if DEBUG
            plugins.append(NetworkLoggingPlugin().allowAll())
        #endif

        // Set the application key for app specific user settings
        User.applicationKey = "CAD"

        // Set the application specific notification handler
        NotificationManager.shared.handler = CADNotificationHandler()
        registerPushNotifications(application)

        let host = APP_HOST_URL
        APIManager.shared = APIManager(configuration: APIManagerDefaultConfiguration(url: "https://\(host)", plugins: plugins, trustPolicyManager: ServerTrustPolicyManager(policies: [host: .disableEvaluation])))

        // Use demo data
        CADStateManager.shared = CADStateManagerCore(apiManager: DemoAPIManager.shared)

        landingPresenter = LandingPresenter()
        landingPresenter.wantsBiometricAuthentication = true
        let presenter = PresenterGroup(presenters: [
            SystemPresenter(), landingPresenter, BookOnPresenter(), TaskListPresenter(), TaskItemPresenter()
        ])
        let director = Director(presenter: presenter)
        Director.shared = director

        let window = UIWindow()
        self.window = window

        // Observe theme changes and apply current theme
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        applyCurrentTheme()

        updateAppForUserSession()

        // TODO: Put this somewhere else I guess. Just need it now for the map.
        if CLLocationManager.authorizationStatus() == .notDetermined {
            LocationManager.shared.requestWhenInUseAuthorization().catch { [weak self] _ in
                self?.showNotificationServicesDisabledAlert()
            }
        } else if CLLocationManager.authorizationStatus() == .denied {
            showNotificationServicesDisabledAlert()
        }
        NotificationManager.shared.requestAuthorizationIfNeeded()
        
        window.makeKeyAndVisible()

        #if !DEBUG
            let manager = BITHockeyManager.shared()
            manager.configure(withIdentifier: HOCKEY_APP_IDENTIFIER)
            manager.start()

            manager.updateManager.updateSetting = .checkStartup
            manager.crashManager.crashManagerStatus = .autoSend

            let authenticator = manager.authenticator
            authenticator.authenticationSecret = HOCKEY_SECRET
            authenticator.identificationType = .hockeyAppEmail
            authenticator.authenticateInstallation()
        #endif

        return true
    }

    private func showNotificationServicesDisabledAlert() {
        let alert = PSCAlertController(title: NSLocalizedString("Location services disabled", comment: ""),
                                       message: NSLocalizedString("This service must be turned on for the app to correctly work and determine your call sign's location.", comment: ""),
                                       image: AssetManager.shared.image(forKey: .dialogAlert))
        let settingsAction = PSCAlertAction(title: "Settings", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        
        let cancelAction = PSCAlertAction(title: "Cancel", style: .cancel)
        alert.addActions([settingsAction, cancelAction])
        AlertQueue.shared.add(alert)
    }
    
    private func updateAppForUserSession() {

        // Reload user from shared storage if logged in, in case updated by another mpol app
        if UserSession.current.isActive == true {
            UserSession.current.restoreSession { token in
                APIManager.shared.setAuthenticationPlugin(AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token)))
                UserPreferenceManager.shared.fetchSharedUserPreferences().then(UserPreferenceManager.shared.fetchUserPreferences).cauterize()
            }
        }

        // Update screen if necessary
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

    private func attemptRefresh(response: DataResponse<Data>) -> Promise<Void> {

        let promise: Promise<Void>

        // Create refresh token request with current token
        if let token = UserSession.current.token?.refreshToken {
            promise = APIManager.shared.accessTokenRequest(for: .refreshToken(token))
                .done { token -> Void in
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

        promise.catch { error in
            UserSession.current.endSession()
            self.landingPresenter.updateInterfaceForUserSession(animated: true)
            AlertQueue.shared.addSimpleAlert(title: "Session Ended", message: error.localizedDescription)
        }

        return promise
    }

    @objc private func applyCurrentTheme() {
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reload interface style incase it has changed
        ThemeManager.shared.loadInterfaceStyle()
        
        // Reload user session and update UI to match current state
        updateAppForUserSession()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - APNS

    func registerPushNotifications(_ application: UIApplication) {

        // Request authorisation to receive PNs, then request token from Apple
        // Skip if simulator
        #if !targetEnvironment(simulator)
        _ = NotificationManager.shared.requestAuthorizationIfNeeded().done { _ -> Void in
            application.registerForRemoteNotifications()
        }
        #endif
    }

    // NOTE: This method needs to exist here in app delegate in order to get silent push notifications,
    // regardless of the use of UNUserNotificationCenter!

    /// Called when a remote notification arrives that indicates there is data to be fetched (ie silent push)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle notification (which may trigger network operation), then complete with fetch result
        _ = NotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo).done { result in
            completionHandler(result)
        }
    }

    /// Called when the app has successfully registered with Apple Push Notification service (APNs)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Upload token to server & register for PNS
        NotificationManager.shared.updatePushToken(deviceToken)
    }

    /// Called when Apple Push Notification service cannot successfully complete the registration process
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notification: \(error)")
    }


}

