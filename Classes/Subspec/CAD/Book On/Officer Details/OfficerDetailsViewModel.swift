//
//  OfficerDetailsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class OfficerDetailsViewModel {
    
    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = OfficerDetailsViewController(viewModel: self)
        return vc
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        // TODO: get from user session
        return "Jason Chieng"
    }
    
    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        // TODO: get from user session
        return "Senior Sergeant : #800108"
    }

}
