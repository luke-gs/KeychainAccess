//
//  OfficerListViewModelContainer.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class OfficerListViewModelContainer {
    open var viewModel: GenericSearchViewModel
    
    public init() {
        let items = OfficerListViewModelContainer.sampleData // TODO: Get from network or something
        viewModel = GenericSearchViewModel(items: items)
        viewModel.title = "Add Officer"
    }
    
    open func createViewController() -> OfficerListViewController {
        return OfficerListViewController(viewModel: viewModel)
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
