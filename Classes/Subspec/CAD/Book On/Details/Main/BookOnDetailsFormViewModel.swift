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

/// View model protocol for callsign details
public protocol BookOnCallsignViewModelType {
    var callsign: String {get}
    var status: ResourceStatus? {get}
    var location: String? {get}
    var type: ResourceType? {get}
}

/// Concrete callsign details view model
struct BookOnCallsignViewModel: BookOnCallsignViewModelType {
    var callsign: String
    var status: ResourceStatus?
    var location: String?
    var type: ResourceType?
}

/// View model for the book on details form screen
open class BookOnDetailsFormViewModel {

    /// Delegate for UI updates
    open weak var delegate: BookOnDetailsFormViewModelDelegate?

    /// The form content
    public var content: BookOnDetailsFormContentMainViewModel

    /// View model of selected callsign to book on to
    private var callsignViewModel: BookOnCallsignViewModelType

    /// Whether we are editing an existing bookon
    public let isEditing: Bool

    /// Whether to show vehicle fields
    public let showVehicleFields: Bool = true

    public init(callsignViewModel: BookOnCallsignViewModelType) {
        self.callsignViewModel = callsignViewModel

        // Create equipment selection pickables from manifest items
        let defaultEquipment = CADStateManager.shared.equipmentItems().map { item in
            return QuantityPicked(object: item, count: 0)
        }.sorted(using: [SortDescriptor<QuantityPicked>(ascending: true) { $0.object.title }])

        if let lastSaved = CADStateManager.shared.lastBookOn {
            content = BookOnDetailsFormContentMainViewModel(withModel: lastSaved)
            isEditing = true

            // Apply the previously stored equipment counts to latest manifest data
            var mergedEquipment = defaultEquipment
            for equipment in content.equipment {
                if equipment.count > 0 {
                    // Update count if manifest item still exists
                    if let index = mergedEquipment.index(of: equipment) {
                        mergedEquipment[index].count = equipment.count
                    }
                }
            }
            content.equipment = mergedEquipment
        } else {
            content = BookOnDetailsFormContentMainViewModel()
            isEditing = false

            content.equipment = defaultEquipment

            // Initial form has self as one of officers to be book on to callsign
            if let model = CADStateManager.shared.officerDetails {
                let officer = BookOnDetailsFormContentOfficerViewModel(withModel: model, initial: true)
                content.officers = [officer]
            }
        }
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
            return "\(callsignViewModel.callsign)"
        } else {
            return "Book on \(callsignViewModel.callsign)"
        }
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        if isEditing {
            return NSLocalizedString("Manage Call Sign", comment: "")
        } else {
            return [CADStateManager.shared.officerDetails?.patrolGroup, callsignViewModel.type?.title].joined(separator: ThemeConstants.dividerSeparator)
        }
    }

    open func terminateButtonText() -> String {
        return NSLocalizedString("Terminate shift", comment: "")
    }

    open func terminateShift() {
        if callsignViewModel.status?.canTerminate == true {
            // Update session and dismiss screen
            CADStateManager.shared.setOffDuty()
            delegate?.dismiss(animated: true, completion: nil)
        } else {
            AlertQueue.shared.addSimpleAlert(title: NSLocalizedString("Unable to Terminate Shift", comment: ""),
                                             message: NSLocalizedString("Your call sign is currently responding to an active incident that must first be finalised.", comment: ""))
        }

    }

    open func submitForm() -> Promise<()> {
        // Update session
        let bookOnRequest = content.createModel()
        bookOnRequest.callsign = callsignViewModel.callsign
        CADStateManager.shared.lastBookOn = bookOnRequest

        return firstly {
            // TODO: submit to network
            return Promise(value: ())
        }
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
