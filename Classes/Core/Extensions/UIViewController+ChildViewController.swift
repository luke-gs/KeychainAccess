//
//  UIViewController+ChildViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//
import UIKit

extension UIViewController {
    
    /// Adds a child view controller using its `view` property to the specified view
    func addChildViewController(_ childViewController: UIViewController, toView view: UIView) {
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
    
    /// Removes a child view controller and its `view` property from its superview and parent view controller
    func removeChildViewController(_ childViewController: UIViewController) {
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
}
