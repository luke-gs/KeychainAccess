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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, LoginViewControllerDelegate, TermsConditionsViewControllerDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        MPOLKitInitialize()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .ThemeDidChange, object: nil)
        
        registerPushNotifications(application)
        
        let window = UIWindow()
        self.window = window
        
        applyCurrentTheme()
        
        updateInterface(forLogin: true, animated: false)
        
        window.makeKeyAndVisible()
        
        return true
    }
    
   // MARK: - APNS
    
    func registerPushNotifications(_ application: UIApplication) {
        
        let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.badge,.sound, .alert]) { (granted, error) in
            if error == nil {
                #if !arch(i386) && !arch(x86_64)
                    application.registerForRemoteNotifications()
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
    
    
    // MARK: - Login view controller delegate
    
    func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        let tsAndCsVC = TermsConditionsViewController()
        tsAndCsVC.delegate = self
        let navController = PopoverNavigationController(rootViewController: tsAndCsVC)
        navController.modalPresentationStyle = .formSheet
        controller.present(navController, animated: true)
    }
    
    
    // MARK: - Terms and conditions delegate
    
    func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
        controller.dismiss(animated: true) { 
            if accept {
                self.updateInterface(forLogin: false, animated: true)
            }
        }
    }
    
    
    // MARK: - Private methods
    
    // TEMP
    func logOut() {
        updateInterface(forLogin: true, animated: true)
    }
    
    
    private func updateInterface(forLogin login: Bool, animated: Bool) {
        if login {
            let headerLabel = UILabel(frame: .zero)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.text = "BlueConnect"
            headerLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightSemibold)
            headerLabel.textColor = .white
            headerLabel.adjustsFontSizeToFitWidth = true
            
            let headerImage = UIImageView(image: #imageLiteral(resourceName: "MPOLIcon"))
            headerImage.translatesAutoresizingMaskIntoConstraints = false
            
            let headerView = UIView(frame: .zero)
            headerView.addSubview(headerImage)
            headerView.addSubview(headerLabel)
            
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[hi]-(==20@900)-[hl]|", options: [.alignAllCenterX], metrics: nil, views: ["hi": headerImage, "hl": headerLabel])
            constraints.append(NSLayoutConstraint(item: headerImage, attribute: .centerX, relatedBy: .equal, toItem: headerView, attribute: .centerX))
            NSLayoutConstraint.activate(constraints)
            
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = headerView
            self.window?.rootViewController = loginViewController
        } else {
            
            func settingsBarButtonItem() -> UIBarButtonItem {
                let settingsItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconOtherSettings"), style: .plain, target: self, action: #selector(settingsButtonItemDidSelect(_:)))
                settingsItem.accessibilityLabel = NSLocalizedString("Settings", comment: "SettingsIconAccessibility")
                return settingsItem
            }
            
            let searchViewController = SearchViewController()
            searchViewController.recentsViewController.title = "MPOL" // TODO: Should be client name
            searchViewController.recentsViewController.navigationItem.leftBarButtonItem = settingsBarButtonItem()
            
            let searchNavController = UINavigationController(rootViewController: searchViewController)
            let actionListNavController = UINavigationController(rootViewController: ActionListViewController())
            let eventListNavController = UINavigationController(rootViewController: EventsListViewController())
            
            let tasksProxyViewController = UIViewController()
            tasksProxyViewController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tab Bar Item title")
            tasksProxyViewController.tabBarItem.image = #imageLiteral(resourceName: "iconOtherTask")
            tasksProxyViewController.tabBarItem.selectedImage = #imageLiteral(resourceName: "iconOtherTaskFilled")
            tasksProxyViewController.tabBarItem.isEnabled = false
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [searchNavController, actionListNavController, eventListNavController, tasksProxyViewController]
            
            self.tabBarController = tabBarController
            self.window?.rootViewController = tabBarController
        }
        
        if animated, let window = self.window {
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        let settingsNavController = PopoverNavigationController(rootViewController: SettingsViewController())
        settingsNavController.modalPresentationStyle = .popover
        
        if let popoverController = settingsNavController.popoverPresentationController {
            popoverController.barButtonItem = item
        }
        
        tabBarController?.present(settingsNavController, animated: true)
    }
    
    @objc private func themeDidChange() {
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
        let theme = Theme.current
        
        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(theme.navigationBarBackgroundImage, for: .default)
        navBar.barStyle  = theme.navigationBarStyle
        navBar.tintColor = theme.colors[.NavigationBarTint]
        
        let navBarExtension = NavigationBarExtension.appearance()
        navBarExtension.backgroundImage = theme.navigationBarBackgroundExtensionImage
        navBarExtension.tintColor = theme.colors[.NavigationBarTint]
        
        UITabBar.appearance().barStyle = theme.tabBarStyle
        
        window?.tintColor = theme.colors[.Tint]
        
        AlertQueue.shared.preferredStatusBarStyle = theme.statusBarStyle
    }
    
    
}

