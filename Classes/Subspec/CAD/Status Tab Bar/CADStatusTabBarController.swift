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
    }
    
    @objc open func selectedCallsignStatusView() {
        guard let viewController = viewModel.userCallsignStatusViewModel.createActionViewController() else { return }
        
        let container = PopoverNavigationController(rootViewController: viewController)
        container.modalPresentationStyle = .formSheet
        
        selectedViewController?.present(container, animated: true)
    }
}

extension CADStatusTabBarController: UserCallsignStatusViewModelDelegate {
    public func viewModelStateChanged() {
        userCallsignStatusView.updateViews()
    }
}
