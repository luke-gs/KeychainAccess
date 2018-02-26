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

open class OfficerListViewModel: GenericSearchDefaultViewModel {
    
    open weak var detailsDelegate: OfficerDetailsViewModelDelegate?
    open weak var delegate: OfficerListViewModelDelegate?
    
    public init() {
        super.init(items: viewModelData())
        title = navTitle()
    }
    
    public required init(items: [GenericSearchable]) {
        super.init(items: items)
        title = navTitle()
    }
    
    open func createViewController() -> OfficerListViewController {
        let vc = OfficerListViewController(viewModel: self)
        delegate = vc
        return vc
    }
    
    open func navTitle() -> String {
        return NSLocalizedString("Add Officer", comment: "")
    }
    
    open func sectionTitle() -> String {
        return NSLocalizedString("Recently Used", comment: "")
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
    
    open func viewModelData() -> [GenericSearchable] {
        let section = sectionTitle().uppercased()
        var result: [GenericSearchable] = []
        for (_, officer) in CADStateManager.shared.officersById {
            let viewModel = OfficerListItemViewModel(firstName: officer.firstName, lastName: officer.lastName, initials: officer.initials, rank: officer.rank, callsign: officer.payrollId, section: section)
            result.append(viewModel)
        }
        return result
    }
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

