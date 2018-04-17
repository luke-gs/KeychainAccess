//
//  CreateActivityLogItemViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class CreateActivityLogItemViewModel {

    /// The completion handler for creating new activity log entry
    open var completionHandler: (() -> Void)?

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

    /// MARK: - Actions

    open func submit() {
        completionHandler?()
    }

    open func cancel() {
        completionHandler?()
    }
}
