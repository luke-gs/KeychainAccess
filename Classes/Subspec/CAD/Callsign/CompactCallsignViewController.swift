//
//  CompactCallsignViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 27/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CompactCallsignViewController: UIViewController {

    private var callsignViewController = UIViewController()
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateChildViewControllerIfRequired), name: .CallsignChanged, object: nil)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChildViewControllerIfRequired()
    }

    @objc private func updateChildViewControllerIfRequired() {
        let newCallsignViewController: UIViewController
        
        if CADUserSession.current.callsign == nil {
            newCallsignViewController = NotBookedOnViewModel().createViewController()
        } else {
            newCallsignViewController = ManageCallsignStatusViewModel().createViewController()
        }
        
        // Do nothing if new VC is the same type as the old one
        guard type(of: callsignViewController) != type(of: newCallsignViewController) else { return }
        
        removeChildViewController(callsignViewController)
        
        let navController = UINavigationController(rootViewController: newCallsignViewController)
        
        addChildViewController(navController, toView: view)
        callsignViewController = newCallsignViewController
        callsignViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
