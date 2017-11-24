//
//  CADStatusTabBarController.swift
//  ClientKit
//
//  Created by Kyle May on 8/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// CAD implementation of status tab bar with callsign status
open class CADStatusTabBarController: StatusTabBarController {
    
    private var syncObserver: NSObjectProtocol?
    
    open let viewModel: CADStatusTabBarViewModel
    open var userCallsignStatusView: UserCallsignStatusView!
    
    public init(viewModel: CADStatusTabBarViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add book on status view to status area
        userCallsignStatusView = viewModel.userCallsignStatusViewModel.createView()
        userCallsignStatusView.addTarget(self, action: #selector(selectedCallsignStatusView), for: .touchUpInside)
        
        statusView = userCallsignStatusView
        tabBar.isTranslucent = false
        
        syncObserver = NotificationCenter.default.addObserver(forName: .CADSyncChanged, object: nil, queue: .main) { _ in
            self.setTabBarEnabled(true)
        }

        setTabBarEnabled(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(syncObserver, name: .CADSyncChanged, object: nil)
    }
    
    /// Sets all the tabs and status view buttons to be enabled or disabled
    open func setTabBarEnabled(_ enabled: Bool) {
        regularViewControllers.forEach {
            $0.tabBarItem.isEnabled = enabled
        }
        compactViewControllers?.forEach {
            $0.tabBarItem.isEnabled = enabled
        }
        
        userCallsignStatusView.isEnabled = enabled
    }
    
    @objc open func selectedCallsignStatusView() {
        guard userCallsignStatusView.isEnabled,
            let viewController = viewModel.userCallsignStatusViewModel.createActionViewController()
        else { return }
        
        let container = PopoverNavigationController(rootViewController: viewController)
        container.modalPresentationStyle = .formSheet
        
        // Less transparent background to give more contrast for forms
        container.lightTransparentBackground = UIColor(white: 1, alpha: 0.5)
        
        selectedViewController?.present(container, animated: true)
    }
}

