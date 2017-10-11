//
//  ResourceOfficerListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewModel: CADFormCollectionViewModel<ResourceOfficerViewModel> {

    /// Create the view controller for this view model
    public func createViewController() -> ResourceOfficerListViewController {
        return ResourceOfficerListViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    private lazy var data: [CADFormCollectionSectionViewModel<ResourceOfficerViewModel>] = {
        return [
            CADFormCollectionSectionViewModel(title: "2 Officers",
                                              items: [
                                                ResourceOfficerViewModel(title: "Dean McCrae", subtitle: "Senior Constable  :  #820904  :  Gold License", badgeText: "DRIVER", commsEnabled: (text: true, call: true, video: false)),
                                                ResourceOfficerViewModel(title: "Sarah Worrall", subtitle: "Constable  :  #800560  :  Silver License", badgeText: nil, commsEnabled: (text: true, call: true, video: true)),
                ])
        ]
    }()
    
    // MARK: - Override
    
    override open func sections() -> [CADFormCollectionSectionViewModel<ResourceOfficerViewModel>] {
        return data
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Officers", comment: "Officers sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Officers Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }

}
