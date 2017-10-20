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
    
    open let bookOnStatusViewModel: BookOnStatusViewModel
    
    public init(bookOnStatusViewModel: BookOnStatusViewModel) {
        self.bookOnStatusViewModel = bookOnStatusViewModel
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> CADStatusTabBarController {
        return CADStatusTabBarController(viewModel: self)
    }
    
}
