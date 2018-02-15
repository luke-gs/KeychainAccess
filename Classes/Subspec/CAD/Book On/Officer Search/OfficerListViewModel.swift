//
//  OfficerListViewModelContainer.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol OfficerListViewModelDelegate: class {
    func itemSelectedAndFinishedEditing()
}

public class OfficerListViewModel: GenericSearchDefaultViewModel {
    
    open weak var detailsDelegate: OfficerDetailsViewModelDelegate?
    open weak var delegate: OfficerListViewModelDelegate?
    
    public init() {
        super.init(items: viewModelData)
        title = NSLocalizedString("Add Officer", comment: "")
    }
    
    public required init(items: [GenericSearchable]) {
        super.init(items: items)
        title = NSLocalizedString("Add Officer", comment: "")
    }
    
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Officers Found", comment: "")
    }

    open func officerDetailsScreen(for officer: OfficerListItemViewModel) -> Presentable {
        let officerViewModel = BookOnDetailsFormContentOfficerViewModel()
        officerViewModel.title = officer.title
        officerViewModel.rank = officer.rank
        officerViewModel.officerId = officer.callsign
        officerViewModel.initials = officer.initials

        return BookOnScreen.officerDetailsForm(officerViewModel: officerViewModel, delegate: self)
    }
    
    private lazy var viewModelData: [GenericSearchable] = {
        let section = "Recently Used".uppercased()
        var result: [GenericSearchable] = []
        if let syncDetails = CADStateManager.shared.lastSync {
            for officer in syncDetails.officers {
                let viewModel = OfficerListItemViewModel(firstName: officer.firstName, lastName: officer.lastName, initials: officer.initials, rank: officer.rank, callsign: officer.payrollId, section: section)
                result.append(viewModel)
            }
        }
        return result
    }()
}

extension OfficerListViewModel: OfficerDetailsViewModelDelegate {
    public func didFinishEditing(with officer: BookOnDetailsFormContentOfficerViewModel, shouldSave: Bool) {
        detailsDelegate?.didFinishEditing(with: officer, shouldSave: shouldSave)
        // If should save then let the VC know we are done
        if shouldSave {
            delegate?.itemSelectedAndFinishedEditing()
        }
    }
}

