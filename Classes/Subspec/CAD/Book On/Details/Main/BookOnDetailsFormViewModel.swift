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
public protocol BookOnDetailsFormViewModelDelegate: PopoverPresenter {
    /// Called when did update details
    func didUpdateDetails()
}

/// View model for the book on details form screen
open class BookOnDetailsFormViewModel {

    /// Delegate for UI updates
    open weak var delegate: BookOnDetailsFormViewModelDelegate?

    /// The form content
    open private(set) var content: BookOnDetailsFormContentMainViewModel

    /// Resource we are booking on to
    open private(set) var resource: CADResourceType

    /// Whether we are editing an existing bookon
    open let isEditing: Bool

    /// Whether to show vehicle fields
    open let showVehicleFields: Bool = true

    // Array of default equipment items, manifest items with zero counts
    open var defaultEquipment: [QuantityPicked] {
        return CADStateManager.shared.equipmentItems().map { item in
            return QuantityPicked(object: item, count: 0)
        }.sorted(using: [SortDescriptor<QuantityPicked>(ascending: true) { $0.object.title }])
    }

    public init(resource: CADResourceType) {
        self.resource = resource

        if let lastSaved = CADStateManager.shared.lastBookOn {
            content = BookOnDetailsFormContentMainViewModel(withModel: lastSaved)
            isEditing = true
        } else {
            content = BookOnDetailsFormContentMainViewModel(withResource: resource)
            isEditing = false

            // Always make sure we are first officer in list when booking on
            if let loggedInOfficer = CADStateManager.shared.officerDetails {
                // Remove existing
                if let index = resource.payrollIds.index(of: loggedInOfficer.payrollId) {
                    content.officers.remove(at: index)
                }
                // Insert latest officer details at first position
                let officerViewModel = BookOnDetailsFormContentOfficerViewModel(withModel: loggedInOfficer, initial: true)
                content.officers.insert(officerViewModel, at: 0)
            }
        }
        // Convert the selected equipment to quantity picked items, if still in latest manifest data
        content.equipment = updatedEquipmentList(equipment: content.equipment)
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = BookOnDetailsFormViewController(viewModel: self)
        delegate = vc
        return vc
    }

    /// The title to use in the navigation bar
    open func navTitle() -> String {
        if isEditing {
            return "Manage \(resource.callsign)"
        } else {
            return "Book on \(resource.callsign)"
        }
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        if isEditing {
            return ""
        } else {
            return [CADStateManager.shared.patrolGroup, resource.type.title].joined(separator: ThemeConstants.dividerSeparator)
        }
    }

    open func terminateButtonText() -> String {
        return NSLocalizedString("Terminate Shift", comment: "")
    }

    open func terminateShift() {
        if resource.status.canTerminate {
            // Book off unit and dismiss form
            // TODO: add loading state
            _ = CADStateManager.shared.bookOff().done { [weak self] in
                self?.delegate?.dismiss(animated: true, completion: nil)
            }
        } else {
            AlertQueue.shared.addSimpleAlert(title: NSLocalizedString("Unable to Terminate Shift", comment: ""),
                                             message: NSLocalizedString("Your call sign is currently responding to an active incident that must first be finalised.", comment: ""))
        }

    }

    open func submitForm() -> Promise<Void> {
        // Update session
        let bookOnRequest = content.createModel(callsign: resource.callsign)
        return CADStateManager.shared.bookOn(request: bookOnRequest)
    }

    open func officerDetailsScreen(at index: Int? = nil) -> Presentable {
        let officerViewModel: BookOnDetailsFormContentOfficerViewModel
        
        if let index = index, let existingOfficer = content.officers[ifExists: index] {
            officerViewModel = existingOfficer
        } else {
            officerViewModel = BookOnDetailsFormContentOfficerViewModel()
        }

        return BookOnScreen.officerDetailsForm(officerViewModel: officerViewModel, delegate: self)
    }
    
    open func officerSearchScreen() -> Presentable {
        return BookOnScreen.officerList(detailsDelegate: self)
    }

    open func allowRemoveOfficer(at index: Int) -> Bool {
        // Allow removing officer if:
        // - When new book on, any additional officers (not default logged in officer)
        // - When editing existing book on, anyone including logged in officer as long as not the last one in callsign
        if isEditing {
            if content.officers.count > 1 {
                return true
            }

        } else if index > 0 {
            return true
        }
        return false
    }

    open func removeOfficer(at index: Int) {
        content.officers.remove(at: index)
    }

    public func updatedEquipmentList(equipment: [QuantityPicked]) -> [QuantityPicked] {
        // Apply the given equipment counts to the latest manifest data
        var mergedEquipment = defaultEquipment
        for equipment in equipment {
            if equipment.count > 0 {
                // Update count if manifest item still exists
                if let index = mergedEquipment.index(of: equipment) {
                    mergedEquipment[index].count = equipment.count
                }
            }
        }
        return mergedEquipment
    }
}

extension BookOnDetailsFormViewModel: OfficerDetailsViewModelDelegate {
    public func didFinishEditing(with officer: BookOnDetailsFormContentOfficerViewModel, shouldSave: Bool) {
        guard shouldSave else { return }
        
        if let index = content.officers.index(of: officer) {
            content.officers[index] = officer
        } else {
            content.officers.append(officer)
        }

        // Make sure only one officer is marked as driver
        if officer.isDriver.isTrue {
            for otherOfficer in content.officers {
                if otherOfficer != officer {
                    otherOfficer.isDriver = false
                }
            }
        }

        delegate?.didUpdateDetails()
    }
}
