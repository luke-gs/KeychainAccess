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
open class BookOnDetailsFormViewModel: NSObject {

    /// Internal struct for book on details, to be populated by form
    public class Details {
        var serial: String?
        var category: String?
        var odometer: String?
        var equipment: String?
        var remarks: String?
        var startTime: Date?
        var endTime: Date?
        var duration: String?
    }

    public let details = Details()

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = BookOnDetailsFormViewController(viewModel: self)
        return vc
    }

    /// The title to use in the navigation bar
    open func navTitle() -> String {
        // TODO: get from user session
        return "Book on P24"
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        // TODO: get from user session
        return "Collingwood Station : Patrol"
    }

    open func submitForm() -> Promise<Bool> {
        // TODO: submit to network
        return Promise.init(value: true)
    }

}
