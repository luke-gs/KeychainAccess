//
//  CADStatusTabBarController.swift
//  ClientKit
//
//  Created by Kyle May on 8/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class CADStatusTabBarController: StatusTabBarController {
    
    private(set) var callsignView: CallsignStatusView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add callsign view to status area
        callsignView = CallsignStatusView()
        
        // Receive taps from callsign view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedCallsignStatusView))
        callsignView.addGestureRecognizer(tapGestureRecognizer)
        
        statusView = callsignView
        tabBar.isTranslucent = false
    }
    
    @objc private func selectedCallsignStatusView() {
        // TODO: Implement me
    }
}
