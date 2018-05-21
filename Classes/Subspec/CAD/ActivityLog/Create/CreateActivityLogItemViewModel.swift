//
//  CreateActivityLogItemViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

open class CreateActivityLogItemViewModel {

    // Model representing UI
    open var activityType: String?
    open var eventReference: String?
    open var startTime: Date?
    open var endTime: Date?
    open var remarks: String?

    open var activityTypeOptions: [String] {
        return ["Type 1", "Type 2", "Type 3"]
    }

    open var eventReferenceOptions: [String] {
        return ["Reference 1", "Reference 2", "Reference 3"]
    }

    // MARK: - Lifecycle

    public init() {
    }

    open func createViewController() -> UIViewController {
        return CreateActivityLogItemViewController(viewModel: self)
    }

    open func navTitle() -> String {
        return NSLocalizedString("Add activity record", comment: "Add activity record title")
    }

    open func officerList() -> [String]? {
        if let officers = CADStateManager.shared.lastBookOn?.employees {
            return officers.map { return $0.displayName }
        }
        return nil
    }

    // MARK: - Submit

    func submit() -> Promise<Void> {
        return after(seconds: 1).done {}
    }

}
