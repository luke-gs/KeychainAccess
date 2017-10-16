//
//  CADStatusTabBarController.swift
//  ClientKit
//
//  Created by Kyle May on 8/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CADStatusTabBarController: StatusTabBarController {
    
    private(set) var callsignView: CallsignStatusView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add callsign view to status area
        callsignView = CallsignStatusView()
        callsignView.addTarget(self, action: #selector(selectedCallsignStatusView), for: .touchUpInside)
        
        
        statusView = callsignView
        tabBar.isTranslucent = false
    }
    
    @objc private func selectedCallsignStatusView() {
        // TODO: Implement me
    }
}
