//
//  AppDelegate.swift
//  MPOLKit-Example
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
        
        KeyboardInputManager.shared.isNumberBarEnabled = true
        
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
        
        let item1 = SourceItem(title: "CRIMTRAC", state: .loaded(count: 8, color: AlertLevel.high.color))
        let item2 = SourceItem(title: "DS2", state: .loaded(count: 2, color: AlertLevel.low.color))
        let item3 = SourceItem(title: "DS3", state: .loaded(count: 1, color: AlertLevel.low.color))
        
        let sidebarSplitViewController = SidebarSplitViewController(detailViewControllers: [sidebarDetail1VC, sidebarDetail2VC])
        sidebarSplitViewController.sidebarViewController.sourceItems = [item1, item2, item3]
        sidebarSplitViewController.sidebarViewController.selectedSourceIndex = 1
        sidebarSplitViewController.title = "Sidebar SVC"
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [pushableSVNavController, UINavigationController(rootViewController: sidebarSplitViewController), EntityDetailsSplitViewController(entity: NSObject())]
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        return true
    }
    
}

