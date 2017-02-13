//
//  AppDelegate.swift
//  MPOL
//
//  Created by Rod Brown on 13/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = UITabBarController()
        
        let window = UIWindow()
        window.rootViewController = tabBarController
        
        self.window = window
        self.tabBarController = tabBarController
        
        window.makeKeyAndVisible()
        
        return true
    }

}

