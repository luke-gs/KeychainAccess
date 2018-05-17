//
//  CreateIncidentStatusViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View model for the status section in the create incident screen
open class CreateIncidentStatusViewModel: CallsignStatusViewModel {

    // MARK: - Override

    /// Attempt to select a new status
    open override func setSelectedIndexPath(_ indexPath: IndexPath) -> Promise<CADResourceStatusType> {
        self.selectedIndexPath = indexPath
        let newStatus = statusForIndexPath(indexPath)
        return Promise.value(newStatus)
    }

    open override func navTitle() -> String {
        return "Initial Status"
    }
}
