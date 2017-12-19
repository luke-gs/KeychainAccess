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
    
    open func createViewController() -> OfficerListViewController {
        let vc = OfficerListViewController(viewModel: self)
        delegate = vc
        return vc
    }
    
    open func officerDetailsViewController(for officer: OfficerListItemViewModel) -> UIViewController {
        let officerViewModel = BookOnDetailsFormContentOfficerViewModel()
        officerViewModel.title = officer.title
        officerViewModel.rank = officer.rank
        officerViewModel.officerId = officer.callsign
        

        let detailsViewModel = OfficerDetailsViewModel(officer: officerViewModel)
        detailsViewModel.delegate = self
        return detailsViewModel.createViewController()
    }
    
    private lazy var viewModelData: [GenericSearchable] = {
        let section = "Recently Used".uppercased()
        var result: [GenericSearchable] = []
        if let syncDetails = CADStateManager.shared.lastSync {
            for officer in syncDetails.officers {
                let viewModel = OfficerListItemViewModel(firstName: officer.firstName, lastName: officer.lastName, rank: officer.rank, callsign: officer.payrollId, section: section, image: nil)
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

