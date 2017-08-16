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

#if GS_TESTING
import HockeySDK
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, LoginViewControllerDelegate, TermsConditionsViewControllerDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        MPOLKitInitialize()
        
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        
        registerPushNotifications(application)
        
        let window = UIWindow()
        self.window = window
        
        applyCurrentTheme()
        
        updateInterface(forLogin: true, animated: false)
        
        window.makeKeyAndVisible()

        #if GS_TESTING
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
        controller.setLoading(true, animated: true)
        
        MPOLAPIManager.shared.accessTokenRequest(for: .credentials(username: username, password: password)).then { [weak self] _ -> Void in
            guard let `self` = self else { return }
            
            let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!)
            tsAndCsVC.delegate = self
            
            let navController = PopoverNavigationController(rootViewController: tsAndCsVC)
            navController.modalPresentationStyle = .formSheet
            controller.present(navController, animated: true, completion: { [unowned controller] in
                controller.resetFields()
            })
        }.catch { error in
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            AlertQueue.shared.add(alertController)
        }.always {
            controller.setLoading(false, animated: true)
        }
    }
    
    
    // MARK: - Terms and conditions delegate
    
    func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
        controller.dismiss(animated: true) {  [weak self] in
            if accept {
                self?.updateInterface(forLogin: false, animated: true)
            }
        }
    }
    
    func loginViewController(_ controller: LoginViewController, didTapForgotPasswordButton button: UIButton) {
        
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
            headerLabel.text = "mPol"
            headerLabel.font = .systemFont(ofSize: 48.0, weight: UIFontWeightBold)
            headerLabel.textColor = .white
            headerLabel.adjustsFontSizeToFitWidth = true
            
            let subtitleLabel = UILabel(frame: .zero)
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.text = "Mobile Policing Platform"
            subtitleLabel.font = .systemFont(ofSize: 13.0, weight: UIFontWeightSemibold)
            subtitleLabel.textColor = .white
            subtitleLabel.adjustsFontSizeToFitWidth = true
            
            let headerImage = UIImageView(image: #imageLiteral(resourceName: "MPOLIcon"))
            headerImage.translatesAutoresizingMaskIntoConstraints = false
            
            let headerView = UIView(frame: .zero)
            headerView.addSubview(headerImage)
            headerView.addSubview(headerLabel)
            headerView.addSubview(subtitleLabel)
            
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[hi]-(==16@900)-[hl][sl]|", options: [.alignAllCenterX], metrics: nil, views: ["hi": headerImage, "hl": headerLabel, "sl": subtitleLabel])
            constraints.append(NSLayoutConstraint(item: headerImage, attribute: .centerX, relatedBy: .equal, toItem: headerView, attribute: .centerX))
            NSLayoutConstraint.activate(constraints)
            
            let loginViewController = LoginViewController()
            
            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1
            
            loginViewController.delegate = self
            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = headerView
            
            #if DEBUG
            loginViewController.usernameField.text = "mpol"
            loginViewController.passwordField.text = "mock"
            #endif
            
            self.window?.rootViewController = loginViewController
        } else {
            
            func settingsBarButtonItem() -> UIBarButtonItem {
                let settingsItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .settings), style: .plain, target: self, action: #selector(settingsButtonItemDidSelect(_:)))
                settingsItem.accessibilityLabel = NSLocalizedString("Settings", comment: "SettingsIconAccessibility")
                return settingsItem
            }
            
            let searchViewController = SearchViewController(viewModel: MPOLSearchViewModel())
            searchViewController.set(leftBarButtonItem: settingsBarButtonItem())

            let eventListVC = EventsListViewController()
            eventListVC.navigationItem.leftBarButtonItem = settingsBarButtonItem()
            
            let searchNavController = UINavigationController(rootViewController: searchViewController)
            let actionListNavController = UINavigationController(rootViewController: ActionListViewController())
            let eventListNavController = UINavigationController(rootViewController: eventListVC)
            
            let tasksProxyViewController = UIViewController()
            tasksProxyViewController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tab Bar Item title")
            tasksProxyViewController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)
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

