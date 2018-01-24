//
//  FinaliseDetailsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 24/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class FinaliseDetailsViewModel {
    
    
    /// The completion handler for creating new traffic stop incident
    open var completionHandler: ((_ secondaryCode: String?, _ remark: String?) -> Void)?
    
    // Model representing UI
    open var primaryCode: String
    open var secondaryCode: String?
    open var remark: String?
    
    open var secondaryCodeOptions: [String] {
        return ["Assault", "Theft", "Disturbance", "Traffic", "Crash", "Other"]
    }
    
    // MARK: - Lifecycle
    
    public init(primaryCode: String) {
        self.primaryCode = primaryCode
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return FinaliseDetailsViewController(viewModel: self)
    }
    
    
    /// Title for VC
    open func navTitle() -> String {
        return NSLocalizedString("Finalise Incident", comment: "Finalise Incident title")
    }
    
    /// MARK: - Actions
    
    /// Perform any logic when submitting
    open func submit() {
        // Complete with new request
        completionHandler?(secondaryCode, remark)
        completionHandler = nil
    }
    
    /// Perform any logic when cancelling
    open func cancel() {
        // Complete with nothing
        completionHandler?(nil, nil)
        completionHandler = nil
    }
}
