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

private let host = "api-dev.mpol.solutions"
let TermsAndConditionsVersion = "1.0"
let WhatsNewVersion = "1.0"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        MPOLKitInitialize()

        let plugins: [PluginType]?
        #if DEBUG
            plugins = [
                NetworkLoggingPlugin()
            ]
        #else
            plugins = nil
        #endif

        APIManager.shared = APIManager(configuration: APIManagerDefaultConfiguration(url: "https://\(host)", plugins: plugins, trustPolicyManager: ServerTrustPolicyManager(policies: [host: .disableEvaluation])))

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)

        registerPushNotifications(application)

        let window = UIWindow()
        self.window = window
        window.rootViewController = UIViewController()
        
        applyCurrentTheme()

        UserSession.basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        if UserSession.current.isActive == true {
            UserSession.current.restoreSession { [unowned self] token in
                APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
                self.fiddleWithState()
            }
        } else {
            self.updateInterface(for: .login, animated: true)
        }

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

    func fiddleWithState() {
        guard UserSession.current.user?.termsAndConditionsVersionAccepted != TermsAndConditionsVersion else {
            if UserSession.current.user?.whatsNewShownVersion != WhatsNewVersion {
                self.updateInterface(for: .whatsNew, animated: true)
            } else {
                self.updateInterface(for: .landing, animated: true)
            }
            return
        }
        self.updateInterface(for: .login, animated: true)
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
        print(token)

        // TODO: Upload token to server & register for PNS
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notification: \(error)")
    }

    // TEMP
    func logOut() {
        UserSession.current.endSession()
        updateInterface(for: .login, animated: true)
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
