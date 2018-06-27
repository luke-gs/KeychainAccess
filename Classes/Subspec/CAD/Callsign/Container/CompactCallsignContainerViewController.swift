//
//  CompactCallsignContainerViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 27/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Used for switching between not booked on and manage callsign
/// status view controllers as an item in the tab bar in compact mode
open class CompactCallsignContainerViewController: UIViewController, PopToRootable {

    private var callsignViewController = UIViewController()
    private var navController: PopoverNavigationController?
    
    private weak var statusTabController: StatusTabBarController?
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(updateChildViewControllerIfRequired), name: .CADBookOnChanged, object: nil)
        self.statusTabController = statusTabBarController
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChildViewControllerIfRequired()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // If we move to regular, show as a popover
        if (traitCollection.horizontalSizeClass == .unspecified || traitCollection.horizontalSizeClass == .regular), let navController = self.navController {
            removeChildViewController(navController)
            navController.view.translatesAutoresizingMaskIntoConstraints = true
            navController.modalPresentationStyle = .formSheet
            navController.lightTransparentBackground = UIColor(white: 1, alpha: 0.5)
            statusTabController?.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc private func updateChildViewControllerIfRequired() {
        let newCallsignViewController: UIViewController

        if CADStateManager.shared.lastBookOn == nil {
            newCallsignViewController = Director.shared.viewController(forPresentable: BookOnScreen.notBookedOn)
        } else {
            newCallsignViewController = Director.shared.viewController(forPresentable: BookOnScreen.manageBookOn)
        }
        
        // Do nothing if new VC is the same type as the old one, and it is already the child
        if type(of: callsignViewController) == type(of: newCallsignViewController), let navController = self.navController, childViewControllers.contains(navController) {
            return
        }
        
        removeChildViewController(callsignViewController)
        if let navController = self.navController {
            removeChildViewController(navController)
        }
        
        let navController = PopoverNavigationController(rootViewController: newCallsignViewController)
        navController.wantsTransparentBackground = false
        navController.delegate = self
        
        addChildViewController(navController, toView: view)
        callsignViewController = newCallsignViewController
        
        navController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navController.view.topAnchor.constraint(equalTo: view.topAnchor),
            navController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        self.navController = navController
    }
    
    public func popToRoot(animated: Bool) {
        navController?.popToRootViewController(animated: animated)
    }
}

extension CompactCallsignContainerViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.edgesForExtendedLayout.remove(.top)
    }
}
