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
    
    public override init() {
        super.init(items: OfficerListViewModel.sampleData) // TODO: Get from network or something
        title = NSLocalizedString("Add Officer", comment: "")
    }
    
    
    open func createViewController() -> OfficerListViewController {
        let vc = OfficerListViewController(viewModel: self)
        delegate = vc
        return vc
    }
    
    open func officerDetailsViewController(for officer: OfficerListItemViewModel) -> UIViewController {
        let officerViewModel = BookOnDetailsFormContentViewModel.Officer()
        officerViewModel.title = officer.title

        let detailsViewModel = OfficerDetailsViewModel(officer: officerViewModel)
        detailsViewModel.delegate = self
        return detailsViewModel.createViewController()
    }
    
    private static var sampleData: [GenericSearchable] {
        let section = "Recently Used"
        return [
            OfficerListItemViewModel.init(title: "Herli Halim", subtitle: "Senior Sergeant  :  #800256", section: section, image: nil),
            OfficerListItemViewModel.init(title: "Bryan Hathaway", subtitle: "Constable  :  #8005823", section: section, image: nil),
            OfficerListItemViewModel.init(title: "James Aramroongrot", subtitle: "Constable  :  #800851", section: section, image: nil),
            OfficerListItemViewModel.init(title: "Luke Sammut", subtitle: "Constable  :  #820827", section: section, image: nil),
            OfficerListItemViewModel.init(title: "Gavin Raison", subtitle: "Inspector  :  #820904", section: section, image: nil),
            OfficerListItemViewModel.init(title: "Amit Benjamin", subtitle: "Senior Sergeant : #800405", section: section, image: nil),
        ]
    }

}

extension OfficerListViewModel: OfficerDetailsViewModelDelegate {
    public func didFinishEditing(with officer: BookOnDetailsFormContentViewModel.Officer, shouldSave: Bool) {
        detailsDelegate?.didFinishEditing(with: officer, shouldSave: shouldSave)
        // If should save then let the VC know we are done
        if shouldSave {
            delegate?.itemSelectedAndFinishedEditing()
        }
    }
}

