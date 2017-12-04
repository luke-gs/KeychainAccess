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

#if !EXTERNAL
    import EndpointManager
#endif

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

        let refreshToken = RefreshTokenPlugin().onRefreshTokenFailed({ [unowned self] error in
            UserSession.current.endSession()
            self.landingPresenter.updateInterfaceForUserSession(animated: true)
            AlertQueue.shared.addSimpleAlert(title: "Session Ended", message: error?.localizedDescription)
            return Promise(error: error!)
        })

        var plugins: [PluginType] = [refreshToken, NetworkMonitorPlugin()]
        #if DEBUG
            plugins.append(NetworkLoggingPlugin())
        #endif

        // Set the application key for app specific user settings
        User.applicationKey = "Search"

        landingPresenter = LandingPresenter()
        let presenter = PresenterGroup(presenters: [SystemPresenter(), landingPresenter, EntityPresenter()])

        let director = Director(presenter: presenter)
        director.addPresenterObserver(RecentlyViewedTracker())
        
        Director.shared = director

        #if !EXTERNAL
            let endpoint1 = Endpoint(name: "Dev-Latest", url: URL(string: "dev-api-2.mpol.solutions"))
            let endpoint2 = Endpoint(name: "Formal-Test", url: URL(string: "dev-test-api.mpol.solutions"))
            let endpoint3 = Endpoint(name: "Master-Latest", url: URL(string: "master-api.mpol.solutions"))
            let endpoint4 = Endpoint(name: "Client-Demo", url: URL(string: "client-demo-api.mpol.solutions"))
            let endpoint5 = Endpoint(name: "Moto-Demo", url: URL(string: "moto-demo-api.mpol.solutions"))

            EndpointManager.populate([endpoint1, endpoint2, endpoint3, endpoint4, endpoint5])
            EndpointManager.selectedEndpoint = endpoint1

            NotificationCenter.default.addObserver(self, selector: #selector(endpointChanged), name: NSNotification.Name(rawValue: EndpointManager.EndpointChangedNotification), object: nil)

        #endif

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
                APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
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

    // TEMP
    func logOut() {
        UserSession.current.endSession()
        APIManager.shared.authenticationPlugin = nil
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

    #if !EXTERNAL

    // MARK: Endpoints
    @objc private func endpointChanged() {

        guard let endpoint = EndpointManager.selectedEndpoint?.url?.absoluteString else { return }

        var plugins: [PluginType] = [NetworkMonitorPlugin()]

        #if DEBUG
            plugins.append(NetworkLoggingPlugin())
        #endif

        APIManager.shared = APIManager(configuration: APIManagerDefaultConfiguration(url: "https://\(endpoint)", plugins: plugins, trustPolicyManager: ServerTrustPolicyManager(policies: [host: .disableEvaluation])))

        // To re-create the presenter and update the left accessory view of the login view controller with the new endpoint
        // No state is actually fiddled with
        updateAppForUserSession()
    }
    #endif
}
