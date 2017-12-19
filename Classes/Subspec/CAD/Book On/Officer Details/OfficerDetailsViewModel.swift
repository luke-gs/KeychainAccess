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

    /// Delegate for saving changes
    public weak var delegate: OfficerDetailsViewModelDelegate?

    /// The form content
    public var content: BookOnDetailsFormContentOfficerViewModel

    public init(officer: BookOnDetailsFormContentOfficerViewModel) {
        content = BookOnDetailsFormContentOfficerViewModel(withOfficer: officer)
    }
    
    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = OfficerDetailsViewController(viewModel: self)
        return vc
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
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
