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
        
        let sidebarDetail1VC = UIViewController()
        sidebarDetail1VC.title = "Sidebar Test"
        sidebarDetail1VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarInfo")
        sidebarDetail1VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarInfoFilled")
        
        let sidebarDetail2VC = PushableTestViewController(style: .plain)
        sidebarDetail2VC.title = "Sidebar Test 2"
        sidebarDetail2VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarAlert")
        sidebarDetail2VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarAlertFilled")
        
        let sidebarSplitViewController = SidebarSplitViewController(detailViewControllers: [sidebarDetail1VC, sidebarDetail2VC])
        sidebarSplitViewController.sidebarViewController.sourceItems = [SidebarSourceItem(color: .red, title: "CRIMTRAC", count: 8), SidebarSourceItem(color: #colorLiteral(red: 0, green: 0.479532063, blue: 0.9950867295, alpha: 1), title: "DS2", count: 3), SidebarSourceItem(color: .red, title: "DS3", count: 1, isEnabled: false)]
        sidebarSplitViewController.sidebarViewController.selectedSourceIndex = 0
        sidebarSplitViewController.title = "Sidebar SVC"
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [pushableSVNavController, UINavigationController(rootViewController: sidebarSplitViewController)]
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        return true
    }
    
}

