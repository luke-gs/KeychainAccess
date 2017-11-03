//
//  AppDelegate.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Trent Fitzgibbon. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit
import CoreLocation
import Alamofire

let TermsAndConditionsVersion = "1.0"
let WhatsNewVersion = "1.0"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // FIXME: Temporary
    let locationManager = CLLocationManager()

    var currentScreen: LandingScreen?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        MPOLKitInitialize()

        let plugins: [PluginType]?
        #if DEBUG
            plugins = [
                NetworkLoggingPlugin()
            ]
        #else
            plugins = nil
        #endif

        let host = APP_HOST_URL
        APIManager.shared = APIManager(configuration: APIManagerDefaultConfiguration(url: "https://\(host)", plugins: plugins, trustPolicyManager: ServerTrustPolicyManager(policies: [host: .disableEvaluation])))

        let presenter = PresenterGroup(presenters: [SystemPresenter(), LandingPresenter()])
        let director = Director(presenter: presenter)
        Director.shared = director

        let window = UIWindow()
        self.window = window
        
        applyCurrentTheme()

        if UserSession.current.isActive == true {
            UserSession.current.restoreSession { token in
                APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
            }
        }

        updateAppForSessionState()

        // TODO: Put this somewhere else I guess. Just need it now for the map.
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        window.makeKeyAndVisible()
        return true
    }

    private func updateAppForSessionState() {
        let screen: LandingScreen

        if let user = UserSession.current.user, UserSession.current.isActive, user.termsAndConditionsVersionAccepted == TermsAndConditionsVersion {
            if user.whatsNewShownVersion != WhatsNewVersion {
                screen = .whatsNew
            } else {
                screen = .landing
            }
        } else {
            screen = .login
        }

        // Update screen if necessary
        if screen != currentScreen {
            currentScreen = screen
            window?.rootViewController = Director.shared.presenter.viewController(forPresentable: screen)
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        // Show login or session screen depending on user session
        updateAppForSessionState()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

