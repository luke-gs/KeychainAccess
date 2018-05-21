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
open class CallsignStatusViewModel: CADFormCollectionViewModel<ManageCallsignStatusItemViewModel> {

    /// The currently selected state, can be nil
    open var selectedIndexPath: IndexPath?

    /// The display mode of cells when in compact mode
    open var displayMode: CallsignStatusDisplayMode = .auto

    /// The incident related to the resource status
    open private(set) var incident: CADIncidentType?

    /// The current status
    open var currentStatus: CADResourceStatusType? {
        if let selectedIndexPath = selectedIndexPath {
            return statusForIndexPath(selectedIndexPath)
        }
        return nil
    }

    /// Init with sectioned statuses to display, and current selection
    public init(sections: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>],
                selectedStatus: CADResourceStatusType?, incident: CADIncidentType? = nil) {
        super.init()

        self.sections = sections
        self.selectedIndexPath = indexPathForStatus(selectedStatus)
        self.incident = incident
    }
    
    public func reload(sections: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>],
                selectedStatus: CADResourceStatusType?, incident: CADIncidentType?) {
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
    open func setSelectedIndexPath(_ indexPath: IndexPath) -> Promise<CADResourceStatusType> {
        let newStatus = statusForIndexPath(indexPath)
        let currentStatus = self.currentStatus ?? CADClientModelTypes.resourceStatus.defaultCase
        let (allowed, requiresReason) = currentStatus.canChangeToStatus(newStatus: newStatus)
        if allowed {
            var promise: Promise<Void> = Promise<Void>()

            // Requires reason needs further details
            if requiresReason {
                promise = promise.then { _ in
                    return self.promptForStatusReason().then { _ in
                        // TODO: do something with reason
                        return Promise<Void>()
                    }
                }
            }
            switch newStatus.rawValue {
            case CADClientModelTypes.resourceStatus.trafficStopCase.rawValue:
                promise = promise.then { _ in
                    return self.promptForTrafficStopDetails().then { _ in
                        // TODO: do something with traffic stop details collected
                        return Promise<Void>()
                    }
                }
            case CADClientModelTypes.resourceStatus.finaliseCase.rawValue:
                promise = promise.then { _ in
                    return self.promptForFinaliseDetails().then { _ in
                        // TODO: do something with finalise details collected
                        return Promise<Void>()
                    }
                }
            default:
                break
            }

            return promise.map { _ in
                self.selectedIndexPath = indexPath
                return newStatus
            }
        } else {
            let message = NSLocalizedString("Selection not allowed from this state", comment: "")
            return Promise(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
        }
    }
    
    // Prompts the user for more details when tapping on "Traffic Stop" status
    @discardableResult
    open func promptForTrafficStopDetails() -> Promise<CodableRequestParameters> {
        let (promise, resolver) = Promise<CodableRequestParameters>.pending()
        let completionHandler: ((CodableRequestParameters?) -> Void) = { request in
            if let request = request {
                resolver.fulfill(request)
            } else {
                resolver.reject(PMKError.cancelled)
            }
        }
        delegate?.present(BookOnScreen.trafficStop(completionHandler: completionHandler))
        return promise
    }

    // Prompts the user for reason for status change
    @discardableResult
    open func promptForStatusReason() -> Promise<String> {

        let (promise, resolver) = Promise<String>.pending()
        let completionHandler: ((String?) -> Void) = { text in
            if let text = text {
                resolver.fulfill(text)
            } else {
                resolver.reject(PMKError.cancelled)
            }
        }
        delegate?.present(BookOnScreen.statusChangeReason(completionHandler: completionHandler))
        return promise
    }
    
    // Prompts the user for finalise details
    @discardableResult
    open func promptForFinaliseDetails() -> Promise<(String, String)> {
        
        let (promise, resolver) = Promise<(String, String)>.pending()
        let completionHandler: ((String?, String?) -> Void) = { (secondaryCode, remark) in
            if let secondaryCode = secondaryCode, let remark = remark {
                resolver.fulfill((secondaryCode, remark))
            } else {
                resolver.reject(PMKError.cancelled)
            }
        }
        delegate?.present(BookOnScreen.finaliseDetails(primaryCode: incident?.identifier ?? "", completionHandler: completionHandler))
        return promise
    }

    open func statusForIndexPath(_ indexPath: IndexPath) -> CADResourceStatusType {
        return sections[indexPath.section].items[indexPath.item].status
    }

    open func indexPathForStatus(_ status: CADResourceStatusType?) -> IndexPath? {
        guard let status = status else { return nil }

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

    // MARK: - Submit

    func submit() -> Promise<Void> {
        // Update unit status if selected
        if let selectedStatus = currentStatus {
            return CADStateManager.shared.updateCallsignStatus(status: selectedStatus, incident: incident, comments: nil, locationComments: nil)
        }
        return Promise<Void>()
    }

}
