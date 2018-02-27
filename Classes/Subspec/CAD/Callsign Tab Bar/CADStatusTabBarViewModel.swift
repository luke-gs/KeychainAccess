//
//  CADStatusTabBarViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 20/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for the CAD status tab bar
open class CADStatusTabBarViewModel {
    
    open let userCallsignStatusViewModel: UserCallsignStatusViewModel
    
    public init(userCallsignStatusViewModel: UserCallsignStatusViewModel) {
        self.userCallsignStatusViewModel = userCallsignStatusViewModel
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> CADStatusTabBarController {
        return CADStatusTabBarController(viewModel: self)
    }
    
    /// Whether the tab bar should hide until a sync event occurs
    open func shouldHideUntilSynced() -> Bool {
        return true
    }
    
}
