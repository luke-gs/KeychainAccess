//
//  BookOnDetailsFormViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit


/// View model for the book on details form screen
open class BookOnDetailsFormViewModel {

    /// Internal class for book on details, to be populated by form
    public class Details {
        var serial: String?
        var category: String?
        var odometer: String?
        var equipment: String?
        var remarks: String?
        var startTime: Date?
        var endTime: Date?
        var duration: String?
        var officers: [Officer] = []

        public class Officer {
            var title: String?
            var rank: String?
            var officerId: String?
            var licenseType: String?
            var isDriver: Bool?

            var subtitle: String {
                return [rank, officerId, licenseType].removeNils().joined(separator: " : ")
            }
            var status: String? {
                if let isDriver = isDriver, isDriver {
                    return NSLocalizedString("DRIVER", comment: "").uppercased()
                }
                return nil
            }
        }
    }

    /// View model of selected not booked on callsign
    private var callsignViewModel: NotBookedOnItemViewModel

    public let details = Details()

    public init(callsignViewModel: NotBookedOnItemViewModel) {
        self.callsignViewModel = callsignViewModel

        // Initial form has self as one of officers to be book on to callsign
        let selfOfficer = Details.Officer()
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

    open func officerDetailsViewController() -> UIViewController {
        // TODO: show officer details form
        return UIViewController()
    }

}
