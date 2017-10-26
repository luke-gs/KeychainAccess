//
//  BookOnDetailsFormViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// Delegate protocol for updating UI
public protocol BookOnDetailsFormViewModelDelegate: class {
    /// Called when did update details
    func didUpdateDetails()
}

/// View model protocol for callsign details
public protocol BookOnCallsignViewModelType {
    var callsign: String {get}
    var status: String? {get}
    var location: String? {get}
}

/// View model for the book on details form screen
open class BookOnDetailsFormViewModel {

    /// Delegate for UI updates
    open weak var delegate: BookOnDetailsFormViewModelDelegate?

    /// View model of selected callsign to book on to
    private var callsignViewModel: BookOnCallsignViewModelType

    /// Details of book on, edited by form
    public let details = BookOnDetailsFormContentViewModel()

    public init(callsignViewModel: BookOnCallsignViewModelType) {
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
        return "Book on \(callsignViewModel.callsign)"
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        let components = [callsignViewModel.location, callsignViewModel.status].removeNils()
        return components.joined(separator: " : ")
    }

    open func submitForm() -> Promise<Bool> {
        // Update session
        CADUserSession.current.callsign = callsignViewModel.callsign

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
            
        let detailsViewController = OfficerDetailsViewModel(officer: officer)
        detailsViewController.delegate = self
        return detailsViewController.createViewController()
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
