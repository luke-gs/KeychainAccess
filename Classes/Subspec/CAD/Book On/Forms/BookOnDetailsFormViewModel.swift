//
//  BookOnDetailsFormViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol BookOnDetailsFormViewModelDelegate: class {
    /// Called when did update details
    func didUpdateDetails()
}

/// View model for the book on details form screen
open class BookOnDetailsFormViewModel {

    open weak var delegate: BookOnDetailsFormViewModelDelegate?

    /// View model of selected not booked on callsign
    private var callsignViewModel: NotBookedOnItemViewModel

    public let details = BookOnDetailsFormContentViewModel()

    public init(callsignViewModel: NotBookedOnItemViewModel) {
        self.callsignViewModel = callsignViewModel

        // Initial form has self as one of officers to be book on to callsign
        let selfOfficer = BookOnDetailsFormContentViewModel.Officer()
        selfOfficer.title = "Herli Halim"
        selfOfficer.rank = "Senior Sergeant"
        selfOfficer.officerId = "#800256"
        selfOfficer.licenseType = "Gold Licence"
        selfOfficer.isDriver = true

        details.officers = [selfOfficer]
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = BookOnDetailsFormViewController(viewModel: self)
        delegate = vc
        return vc
    }

    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return "Book on \(callsignViewModel.title)"
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        return callsignViewModel.subtitle
    }

    open func submitForm() -> Promise<Bool> {
        // Update session
        CADUserSession.current.callsign = callsignViewModel.title

        // TODO: submit to network
        return Promise(value: true)
    }

    open func officerDetailsViewController(at index: Int? = nil) -> UIViewController {
        let officer: BookOnDetailsFormContentViewModel.Officer
        
        if let index = index, let existingOfficer = details.officers[ifExists: index] {
            officer = existingOfficer
        } else {
            officer = BookOnDetailsFormContentViewModel.Officer()
        }
            
        let detailsViewModel = OfficerDetailsViewModel(officer: officer)
        detailsViewModel.delegate = self
        return detailsViewModel.createViewController()
    }
    
    open func officerSearchViewController() -> UIViewController {
        let searchViewModel = OfficerListViewModel()
        searchViewModel.delegate = self
        return searchViewModel.createViewController()
    }

}

extension BookOnDetailsFormViewModel: OfficerDetailsViewModelDelegate {
    public func didFinishEditing(with officer: BookOnDetailsFormContentViewModel.Officer, shouldSave: Bool) {
        guard shouldSave else { return }
        
        if let index = details.officers.index(of: officer) {
            details.officers[index] = officer
        } else {
            details.officers.append(officer)
            delegate?.didUpdateDetails()
        }
    }
}
