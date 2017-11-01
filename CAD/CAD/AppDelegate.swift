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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var loginViewController: LoginViewController?
    private var sessionViewController: CADStatusTabBarController?
    
    /// The view controller for the callsign tab in compact mode
    private var callsignViewController: UIViewController?

    // FIXME: Temporary
    let locationManager = CLLocationManager()
    
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

        let window = UIWindow()
        self.window = window

        applyCurrentTheme()

        updateAppForSessionState()

        // TODO: Put this somewhere else I guess. Just need it now for the map.
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        window.makeKeyAndVisible()
        return true
    }

    private func updateAppForSessionState() {
        if CADUserSession.current.isActive {
            loginViewController = nil
            if window?.rootViewController == nil || window?.rootViewController != sessionViewController {
                CADUserSession.current.restoreSession { token in
                    APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
                }
                window?.rootViewController = createSessionViewController()
            }
        } else {
            sessionViewController = nil
            if window?.rootViewController == nil || window?.rootViewController != loginViewController {
                window?.rootViewController = createLoginViewController()
            }
        }
    }

    private func createSessionViewController() -> UIViewController {
        let callsignViewController = CompactCallsignViewController()
        callsignViewController.tabBarItem = UITabBarItem(title: "Callsign", image: AssetManager.shared.image(forKey: .entityCar), selectedImage: nil)
        
        let searchProxyViewController = UIViewController() // TODO: Take me back to the search app
        searchProxyViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        searchProxyViewController.tabBarItem.isEnabled = false

        let tasksListContainerViewModel = TasksListContainerViewModel(headerViewModel: TasksListHeaderViewModel(), listViewModel: TasksListViewModel())
        let tasksSplitViewModel = TasksSplitViewModel(listContainerViewModel: tasksListContainerViewModel,
                                                      mapViewModel: TasksMapViewModel())
        let tasksNavController = UINavigationController(rootViewController: tasksSplitViewModel.createViewController())
        tasksNavController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)
        tasksNavController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tasks Tab Bar Item")

        let activityLogViewModel = ActivityLogViewModel()
        let activityNavController = UINavigationController(rootViewController: activityLogViewModel.createViewController())
        activityNavController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarActivity)
        activityNavController.tabBarItem.title = NSLocalizedString("Activity Log", comment: "Activity Log Tab Bar Item")

        let userCallsignStatusViewModel = UserCallsignStatusViewModel()
        let statusTabBarViewModel = CADStatusTabBarViewModel(userCallsignStatusViewModel: userCallsignStatusViewModel)
        let sessionViewController = statusTabBarViewModel.createViewController()

        sessionViewController.regularViewControllers = [searchProxyViewController, tasksNavController, activityNavController]
        sessionViewController.compactViewControllers = sessionViewController.viewControllers + [callsignViewController]
        sessionViewController.selectedViewController = tasksNavController
        self.sessionViewController = sessionViewController
        return sessionViewController
    }
    


    private func createLoginViewController() -> UIViewController {
        let loginViewController = LoginViewController()
        self.loginViewController = loginViewController
        return loginViewController
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

