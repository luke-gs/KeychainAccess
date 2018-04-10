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

public class OfficerListViewModel: DefaultSearchDisplayableViewModel {
    
    open weak var detailsDelegate: OfficerDetailsViewModelDelegate?
    open weak var delegate: OfficerListViewModelDelegate?
    
    public init() {
        let section =  NSLocalizedString("Recently Used", comment: "").uppercased()
        var result: [CustomSearchDisplayable] = []
        for (_, officer) in CADStateManager.shared.officersById {
            let viewModel = OfficerListItemViewModel(firstName: officer.firstName, lastName: officer.lastName, initials: officer.initials, rank: officer.rank, callsign: officer.payrollId, section: section)
            result.append(viewModel)
        }

        super.init(items: result)
        title = navTitle()
    }
    
    public required init(items: [CustomSearchDisplayable]) {
        super.init(items: items)
        title = navTitle()
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
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

