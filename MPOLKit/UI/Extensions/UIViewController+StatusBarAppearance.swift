//
//  UIViewController+StatusBarAppearance.swift
//  VCom
//
//  Created by Rod Brown on 24/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return topViewController
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return topViewController
    }
}

extension UITabBarController {
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return selectedViewController
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return selectedViewController
    }
}

extension UISplitViewController {
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return viewControllers.first
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return viewControllers.first
    }
}
