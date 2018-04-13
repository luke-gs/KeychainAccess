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

    var navigator: AppURLNavigator!

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

        // Set the application specific notification handler
        NotificationManager.shared.handler = SearchNotificationHandler()
        registerPushNotifications(application)

        landingPresenter = LandingPresenter()
        let presenter = PresenterGroup(presenters: [SystemPresenter(), landingPresenter, EntityPresenter(), EventPresenter()])

        let director = Director(presenter: presenter)

        Director.shared = director

        APIManager.shared = APIManager(configuration: APIManagerDefaultConfiguration(url: "https://\(host)", plugins: plugins, trustPolicyManager: ServerTrustPolicyManager(policies: [host: .disableEvaluation])))

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)

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

        setupNavigator()

        return true
    }

    private func updateAppForUserSession() {

        // Reload user from shared storage if logged in, in case updated by another mpol app
        if UserSession.current.isActive == true {
            UserSession.current.restoreSession { token in
                APIManager.shared.setAuthenticationPlugin(AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token)), rule: .blacklist(DefaultFilterRules.authenticationFilterRules))
                NotificationManager.shared.registerPushToken()
            }
        }

        // Update screen if necessary
        landingPresenter.updateInterfaceForUserSession(animated: false)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reload user session and update UI to match current state
        updateAppForUserSession()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if UserSession.current.isActive == true {
            installShortcuts(on: application)
        } else {
            removeShortcuts(from: application)
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if navigator.isRegistered(url) {
            return navigator.handle(url)
        }

        // Return magic value. Magic is good.
        return true
    }

    // MARK: - APNS
    
    func registerPushNotifications(_ application: UIApplication) {

        // Request authorisation to receive PNs, then request token from Apple
        // Skip if simulator
        #if !arch(i386) && !arch(x86_64)
        _ = NotificationManager.shared.requestAuthorizationIfNeeded().then { _ -> Void in
            application.registerForRemoteNotifications()
        }
        #endif
    }

    // NOTE: This method needs to exist here in app delegate in order to get silent push notifications,
    // regardless of the use of UNUserNotificationCenter!

    /// Called when a remote notification arrives that indicates there is data to be fetched (ie silent push)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle notification (which may trigger network operation), then complete with fetch result
        _ = NotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo).then { result in
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

        removeShortcuts(from: UIApplication.shared)
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

    private func setupNavigator() {
        navigator = AppURLNavigator.default

        let launcher = SearchActivityLauncher.default
        let searchHandler = SearchActivityHandler(scheme: launcher.scheme)
        searchHandler.delegate = self
        navigator.register(searchHandler)
    }

    private lazy var searchLauncher: SearchActivityLauncher = {
        return SearchActivityLauncher()
    }()

    private lazy var taskLauncher: AppLaunchActivityLauncher = {
        return AppLaunchActivityLauncher(scheme: CAD_APP_SCHEME)
    }()

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        let handled = handleShortcutItem(shortcutItem)
        completionHandler(handled)

    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {

        guard SupportedShortcut(type: shortcutItem.type) != nil else {
            return false
        }

        var handled = false
        // Considered handled if type is one of the following, regardless whether
        // the handling is successfully completed or not.
        switch shortcutItem.type {
        case SupportedShortcut.searchPerson.type:
            let activity = SearchActivity.searchEntity(term: Searchable(text: nil, type: "Person"))
            try? searchLauncher.launch(activity, using: navigator)
            handled = true
        case SupportedShortcut.searchVehicle.type:
            let activity = SearchActivity.searchEntity(term: Searchable(text: nil, type: "Vehicle"))
            try? searchLauncher.launch(activity, using: navigator)
            handled = true
        case SupportedShortcut.launchTasks.type:
            let activity = AppLaunchActivity.open
            try? taskLauncher.launch(activity, using: navigator)
            handled = true
        default:
            handled = false
        }

        return handled
    }

}

// MARK: - Handling Search Activity
extension AppDelegate: SearchActivityHandlerDelegate {

    func searchActivityHandler(_ handler: SearchActivityHandler, launchedSearchActivity: SearchActivity) {

        // FIXME: Probably need something that knows how to coordinate all of these `from` and `to` businesses.
        switch launchedSearchActivity {
        case .searchEntity(let term):
            landingPresenter.switchTo(.search)
            landingPresenter.searchViewController.beginSearch(with: term)
        case .viewDetails(let id, let entityType, let source):

            let entity: Entity?

            switch entityType {
            case "Person":
                entity = Person(id: id)
            case "Vehicle":
                entity = Vehicle(id: id)
            case "Address":
                entity = Address(id: id)
            case "Organisation":
                // Not supported yet
                entity = nil
                print("Not supported yet")
            default:
                // Do nothing
                entity = nil
                assertionFailure("\(entityType) is not supported.")
            }

            if let entity = entity {
                entity.source = MPOLSource(rawValue: source)
                let presentable = EntityScreen.entityDetails(entity: entity, delegate: nil)

                Director.shared.present(presentable, fromViewController: landingPresenter.searchViewController)
            }
        }
    }

}
