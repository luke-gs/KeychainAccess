//
//  AppDelegate.swift
//  MPOLKit-Example
//
//  Created by Rod Brown on 15/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//


import UIKit
import MPOLKit
import Unbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginViewControllerDelegate {
    
    var window: UIWindow?
    
    private var delayedNetworkEndTimer: Timer?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkActivityDidBegin), name: .NetworkActivityDidBegin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkActivityDidEnd),   name: .NetworkActivityDidEnd,   object: nil)
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        MPOLKitInitialize()
        
        let theme = Theme.current
        
        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(theme.navigationBarBackgroundImage, for: .default)
        navBar.barStyle  = theme.navigationBarStyle
        navBar.tintColor = theme.colors[.NavigationBarTint]
        
        let window = UIWindow()
        window.tintColor = theme.colors[.Tint]
        self.window = window
        
        updateInterface(forLogin: false, animated: false)
        
        window.makeKeyAndVisible()
        
        return true
    }
    
    private func updateInterface(forLogin login: Bool, animated: Bool) {
        if login {
            let headerLabel = UILabel(frame: .zero)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.text = "The MPOL Project"
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
            
            let detailViewController = TestCollectionViewController()
            let pushableSplitViewController = PushableSplitViewController(viewControllers: [UINavigationController(rootViewController: PushableTestViewController(style: .grouped)), UINavigationController(rootViewController: detailViewController)])
            detailViewController.navigationItem.leftBarButtonItem = pushableSplitViewController.embeddedSplitViewController.displayModeButtonItem
            detailViewController.navigationItem.leftItemsSupplementBackButton = true
            pushableSplitViewController.title = "Pushable SVC"
            let pushableSVNavController = UINavigationController(rootViewController: pushableSplitViewController)
            
            let sidebarDetail1VC = UIViewController()
            sidebarDetail1VC.title = "Sidebar Test"
            sidebarDetail1VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarInfo")
            sidebarDetail1VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarInfoFilled")
            
            let sidebarDetail2VC = PushableTestViewController(style: .plain)
            sidebarDetail2VC.title = "Sidebar Test 2"
            sidebarDetail2VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarAlert")
            sidebarDetail2VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarAlertFilled")
            
            let item1 = SourceItem(title: "CRIMTRAC", state: .loaded(count: 8, color: Alert.Level.high.color))
            let item2 = SourceItem(title: "DS2", state: .loaded(count: 2, color: Alert.Level.low.color))
            let item3 = SourceItem(title: "DS3", state: .loaded(count: 1, color: Alert.Level.low.color))
            
            let sidebarSplitViewController = SidebarSplitViewController(detailViewControllers: [sidebarDetail1VC, sidebarDetail2VC])
            sidebarSplitViewController.sidebarViewController.sourceItems = [item1, item2, item3]
            sidebarSplitViewController.sidebarViewController.selectedSourceIndex = 1
            sidebarSplitViewController.title = "Sidebar SVC"
            
            let tabBarController = UITabBarController()
            
            
            let bundle = Bundle(for: Person.self)
            let url = bundle.url(forResource: "Person_25625aa4-3394-48e2-8dbc-2387498e16b0", withExtension: "json", subdirectory: "Mock JSONs")!
            let data = try! Data(contentsOf: url)
            
            let person: Person = try! unbox(data: data)

            tabBarController.viewControllers = [pushableSVNavController, UINavigationController(rootViewController: sidebarSplitViewController), EntityDetailsSplitViewController(entity: person)]
            self.window?.rootViewController = tabBarController
        }
        
        if animated, let window = self.window {
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    // MARK: - Login view controller delegate
    
    func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String) {
        controller.view.endEditing(true)
        updateInterface(forLogin: false, animated: true)
    }
    
    
    // MARK: - Network activity
    
    @objc private func networkActivityDidBegin() {
        delayedNetworkEndTimer?.invalidate()
        delayedNetworkEndTimer = nil
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @objc private func networkActivityDidEnd() {
        delayedNetworkEndTimer?.invalidate()
        
        if #available(iOS 10, *) {
            delayedNetworkEndTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_: Timer) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.delayedNetworkEndTimer = nil
            }
        } else {
            delayedNetworkEndTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(hideNetworkActivityIndicator(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use block based timer APIs on iOS 10 and later.")
    @objc private func hideNetworkActivityIndicator(_ timer: Timer) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        delayedNetworkEndTimer = nil
    }
    
}

    
            
    
