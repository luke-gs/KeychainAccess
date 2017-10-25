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
    
    private var parentDetails: BookOnDetailsFormViewModel.Details.Officer
    public var editingDetails: BookOnDetailsFormViewModel.Details.Officer
    
    public init(officer: BookOnDetailsFormViewModel.Details.Officer) {
        parentDetails = officer
        
        editingDetails = BookOnDetailsFormViewModel.Details.Officer()
        editingDetails.contactNumber = parentDetails.contactNumber
        editingDetails.license = parentDetails.license
        editingDetails.capabilities = parentDetails.capabilities
        editingDetails.remarks = parentDetails.remarks
        editingDetails.isDriver = parentDetails.isDriver
    }
    
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
        parentDetails.contactNumber = editingDetails.contactNumber
        parentDetails.license = editingDetails.license
        parentDetails.capabilities = editingDetails.capabilities
        parentDetails.remarks = editingDetails.remarks
        parentDetails.isDriver = editingDetails.isDriver
        
        return Promise(value: true)
    }
}
