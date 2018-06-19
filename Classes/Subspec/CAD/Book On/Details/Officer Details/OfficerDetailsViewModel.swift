//
//  OfficerDetailsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class OfficerDetailsViewModel {

    /// Delegate for saving changes
    public weak var delegate: OfficerDetailsViewModelDelegate?

    /// The form content
    public var content: BookOnDetailsFormContentOfficerViewModel

    open var licenseOptions: [String] {
        return CADStateManager.shared.manifestEntries(for: .officerLicenceType).rawValues()
    }

    open var capabilitiesOptions: [String] {
        return CADStateManager.shared.manifestEntries(for: .officerCapability).rawValues()
    }

    public init(officer: BookOnDetailsFormContentOfficerViewModel) {
        content = BookOnDetailsFormContentOfficerViewModel(withOfficer: officer)
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        let vc = OfficerDetailsViewController(viewModel: self)
        return vc
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {

        // Set custom title if logged in officer details
        if content.officerId == CADStateManager.shared.officerDetails?.payrollId {
            return NSLocalizedString("My Details", comment: "")
        }
        return content.title ?? ""
    }
    
    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        return content.subtitle
    }

    /// Submits the form
    public func saveForm() {
        delegate?.didFinishEditing(with: content, shouldSave: true)
    }
    
    /// Cancels submitting the form
    public func cancelForm() {
        delegate?.didFinishEditing(with: content, shouldSave: false)
    }
}

public protocol OfficerDetailsViewModelDelegate: class {
    func didFinishEditing(with officer: BookOnDetailsFormContentOfficerViewModel, shouldSave: Bool)
}
