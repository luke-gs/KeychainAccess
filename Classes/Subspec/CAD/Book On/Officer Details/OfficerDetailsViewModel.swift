//
//  OfficerDetailsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public class OfficerDetailsViewModel {
    
    public class OfficerDetails {
        var contactNumber: String?
        var license: String?
        var capabilities: String?
        var remarks: String?
        var driver: Bool?
    }
    
    public var officerDetails = OfficerDetails()

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

    /// Submits the form
    public func saveForm() -> Promise<Bool> {
        // TODO: Submit
        return Promise(value: true)
    }
}
