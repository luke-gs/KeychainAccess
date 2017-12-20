//
//  CallsignStatusViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View model for the callsign status screen
open class CallsignStatusViewModel: CADStatusViewModel {

    /// The incident related to the resource status
    open private(set) var incident: SyncDetailsIncident?

    /// The current status
    open var currentStatus: ResourceStatus? {
        if let selectedIndexPath = selectedIndexPath {
            return statusForIndexPath(selectedIndexPath)
        }
        return nil
    }

    /// Init with sectioned statuses to display, and current selection
    public init(sections: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>],
                selectedStatus: ResourceStatus, incident: SyncDetailsIncident?) {
        super.init()

        self.sections = sections
        self.selectedIndexPath = indexPathForStatus(selectedStatus)
        self.incident = incident
    }

    /// Create the view controller for this view model
    public func createViewController() -> CallsignStatusViewController {
        let vc = CallsignStatusViewController(viewModel: self)
        self.delegate = vc
        return vc
    }

    /// Attempt to select a new status
    open func setSelectedIndexPath(_ indexPath: IndexPath) -> Promise<ResourceStatus> {
        let newStatus = statusForIndexPath(indexPath)
        if (currentStatus ?? .unavailable).canChangeToStatus(newStatus: newStatus) {
            var promise: Promise<Void> = Promise<Void>()

            // Traffic stop requires further details
            if case .trafficStop = newStatus {
                promise = promptForTrafficStopDetails().then { _ -> Void in
                    // TODO: Submit traffic stop details
                }
            }

            return promise.then {
                // TODO: Submit callsign request
                return after(seconds: 1.0)
                }.then { _ -> Promise<ResourceStatus> in
                    // Update UI
                    self.selectedIndexPath = indexPath
                    CADStateManager.shared.updateCallsignStatus(status: newStatus, incident: self.incident)
                    return Promise(value: newStatus)
            }
        } else {
            let message = NSLocalizedString("Selection not allowed from this state", comment: "")
            return Promise(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
        }
    }

    // Prompts the user for more details when tapping on "Traffic Stop" status
    open func promptForTrafficStopDetails() -> Promise<TrafficStopRequest> {
        let viewModel = TrafficStopViewModel()
        delegate?.presentPushedViewController(viewModel.createViewController(), animated: true)
        return viewModel.promise.promise
    }

    open func statusForIndexPath(_ indexPath: IndexPath) -> ResourceStatus {
        return sections[indexPath.section].items[indexPath.item].status
    }

    open func indexPathForStatus(_ status: ResourceStatus) -> IndexPath? {
        // Find the status in the section data
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item.status == status {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    open override func navTitle() -> String {
        return NSLocalizedString("My Status", comment: "")
    }

    /// Hide arrows
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }
}
