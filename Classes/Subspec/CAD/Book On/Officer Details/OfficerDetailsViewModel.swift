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
    
    public var details: BookOnDetailsFormViewModel.Details.Officer
    
    public weak var delegate: OfficerDetailsViewModelDelegate?
    
    public init(officer: BookOnDetailsFormViewModel.Details.Officer) {
        details = BookOnDetailsFormViewModel.Details.Officer(withOfficer: officer)

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
    public func saveForm() {
        delegate?.didFinishEditing(with: details, shouldSave: true)
    }
    
    /// Cancels submitting the form
    public func cancelForm() {
        delegate?.didFinishEditing(with: details, shouldSave: false)
    }
}

public protocol OfficerDetailsViewModelDelegate: class {
    func didFinishEditing(with officer: BookOnDetailsFormViewModel.Details.Officer, shouldSave: Bool)
}
