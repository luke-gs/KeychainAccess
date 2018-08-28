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

#if INTERNAL || EXTERNAL
    import HockeySDK
#endif

private let host = APP_HOST_URL

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var landingPresenter: LandingPresenter!
    var navigator: AppURLNavigator!

    var plugins: [Plugin]?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        MPOLKitInitialize()

        let refreshTokenPlugin = RefreshTokenPlugin { response -> Promise<Void> in
            self.attemptRefresh(response: response)
        }.withRule(.blacklist((DefaultFilterRules.authenticationFilterRules)))

        var plugins: [Plugin] = [refreshTokenPlugin, NetworkMonitorPlugin().allowAll(), SessionPlugin().allowAll(), GeolocationPlugin().allowAll()]

        #if DEBUG
            plugins.append(NetworkLoggingPlugin().allowAll())
        #endif

        self.plugins = plugins

        // Set the application key for app specific user settings
        User.applicationKey = "Search"

        // Set the application specific notification handler
        NotificationManager.shared.handler = SearchNotificationHandler()

        registerPushNotifications(application)

        landingPresenter = LandingPresenter()
        landingPresenter.wantsBiometricAuthentication = true
        let presenter = PresenterGroup(presenters: [SystemPresenter(), landingPresenter, EntityPresenter(), EventPresenter()])

        let director = Director(presenter: presenter)

        Director.shared = director

        APIManager.shared = apiManager(with: APIURLManager.serverURL)

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)

        let window = UIWindow()
        self.window = window

        applyCurrentTheme()

        updateAppForUserSession()
    
        window.makeKeyAndVisible()

        #if INTERNAL || EXTERNAL
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

        setupNavigator()
        startPrepopulationProcessIfNecessary()

        return true
    }

    private func updateAppForUserSession() {

        // Reload user from shared storage if logged in, in case updated by another mpol app
        if UserSession.current.isActive == true {
            UserSession.current.restoreSession { token in
                APIManager.shared.setAuthenticationPlugin(AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token)), rule: .blacklist(DefaultFilterRules.authenticationFilterRules))
                NotificationManager.shared.registerPushToken()
                UserPreferenceManager.shared.fetchSharedUserPreferences()
            }
        }

        // Update screen if necessary
        landingPresenter.updateInterfaceForUserSession(animated: false)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reload interface style incase it has changed
        ThemeManager.shared.loadInterfaceStyle()

        // Reload user session and update UI to match current state
        updateAppForUserSession()

        if let url = try? APIURLManager.serverURL.asURL(), let currentURL = try? APIManager.shared.configuration.url.asURL(),
            url != currentURL {
            if UserSession.current.isActive {
                LogOffManager.shared.requestLogOff()
            }
            APIManager.shared = apiManager(with: url)
        }

        guard let window = window else { return }
        Concealer.default.reveal(window, from: .springboard)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let window = window {
            Concealer.default.conceal(window, from: .springboard)
        }
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

    private func apiManager(with urlConvertible: URLConvertible) -> APIManager {

        // App won't work without, no recovery from here if it's not correct.
        let url = try! urlConvertible.asURL()
        let host = url.host!

        let trustPolicyManager: ServerTrustPolicyManager?
        #if DEBUG
            trustPolicyManager = ServerTrustPolicyManager(policies: [host: .disableEvaluation])
        #else
            trustPolicyManager = nil
        #endif

        return APIManager(configuration: APIManagerDefaultConfiguration(url: url, plugins: plugins, trustPolicyManager: trustPolicyManager))
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
