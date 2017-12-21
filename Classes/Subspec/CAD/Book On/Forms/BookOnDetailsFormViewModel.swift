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
public protocol BookOnDetailsFormViewModelDelegate: class {
    /// Called when did update details
    func didUpdateDetails()
}

/// View model protocol for callsign details
public protocol BookOnCallsignViewModelType {
    var callsign: String {get}
    var status: String? {get}
    var location: String? {get}
    var type: ResourceType? {get}
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

    open func officerDetailsViewController(at index: Int? = nil) -> UIViewController {
        let officer: BookOnDetailsFormContentOfficerViewModel
        
        if let index = index, let existingOfficer = content.officers[ifExists: index] {
            officer = existingOfficer
        } else {
            officer = BookOnDetailsFormContentOfficerViewModel()
        }
            
        let detailsViewModel = OfficerDetailsViewModel(officer: officer)
        detailsViewModel.delegate = self
        return detailsViewModel.createViewController()
    }
    
    open func officerSearchViewController() -> UIViewController {
        let searchViewModel = OfficerListViewModel()
        searchViewModel.detailsDelegate = self
        return searchViewModel.createViewController()
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
