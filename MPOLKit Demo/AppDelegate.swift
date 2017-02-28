//
//  AppDelegate.swift
//  MPOLKit Demo
//
//  Created by Rod Brown on 15/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//


import UIKit
import MPOLKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let theme = Theme.current
        
        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(theme.navigationBarBackgroundImage, for: .default)
        navBar.barStyle  = theme.navigationBarStyle
        navBar.tintColor = theme.colors[.NavigationBarTint]
        
        let window = UIWindow()
        window.tintColor = theme.colors[.Tint]
        self.window = window
        
        let detailViewController = TestCollectionViewController()
        let pushableSplitViewController = PushableSplitViewController(viewControllers: [UINavigationController(rootViewController: PushableTestViewController(style: .grouped)), UINavigationController(rootViewController: detailViewController)])
        detailViewController.navigationItem.leftBarButtonItem = pushableSplitViewController.embeddedSplitViewController.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        pushableSplitViewController.title = "Pushable SVC"
        let pushableSVNavController = UINavigationController(rootViewController: pushableSplitViewController)
        
        let menuDetail1VC = UIViewController()
        menuDetail1VC.title = "Menu Test"
        menuDetail1VC.menuItem.image = #imageLiteral(resourceName: "MenuInfo")
        menuDetail1VC.menuItem.selectedImage = #imageLiteral(resourceName: "MenuInfoFilled")
        
        let menuDetail2VC = PushableTestViewController(style: .plain)
        menuDetail2VC.title = "Menu Test 2"
        menuDetail2VC.menuItem.image = #imageLiteral(resourceName: "MenuAlert")
        menuDetail2VC.menuItem.selectedImage = #imageLiteral(resourceName: "MenuAlertFilled")
        
        let menuSplitViewController = MenuSplitViewController(detailViewControllers: [menuDetail1VC, menuDetail2VC])
        menuSplitViewController.menuViewController.sourceItems = [SourceItem(color: .red, title: "CRIMTRAC", count: 8), SourceItem(color: #colorLiteral(red: 0, green: 0.479532063, blue: 0.9950867295, alpha: 1), title: "DS2", count: 3), SourceItem(color: .red, title: "DS3", count: 1, isEnabled: false)]
        menuSplitViewController.menuViewController.selectedSourceIndex = 0
        menuSplitViewController.title = "Menu SVC"
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [pushableSVNavController, UINavigationController(rootViewController: menuSplitViewController)]
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        return true
    }
    
}

