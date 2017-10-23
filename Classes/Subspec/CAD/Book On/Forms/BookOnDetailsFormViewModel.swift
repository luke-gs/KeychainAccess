//
//  BookOnDetailsFormViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class BookOnDetailsFormViewModel: NSObject {

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


}
