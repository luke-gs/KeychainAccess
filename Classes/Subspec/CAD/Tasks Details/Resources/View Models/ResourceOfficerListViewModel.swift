//
//  ResourceOfficerListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewModel: CADFormCollectionViewModel<ResourceOfficerViewModel>, TaskDetailsViewModel {
    
    public override init() {
        super.init()
        sections = dummyData
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return ResourceOfficerListViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    private lazy var dummyData: [CADFormCollectionSectionViewModel<ResourceOfficerViewModel>] = {
        return [
            CADFormCollectionSectionViewModel(title: "2 Officers",
                                              items: [
                                                ResourceOfficerViewModel(title: "Dean McCrae", subtitle: "Senior Constable  :  #820904  :  Gold License", badgeText: "DRIVER", commsEnabled: (text: true, call: true)),
                                                ResourceOfficerViewModel(title: "Sarah Worrall", subtitle: "Constable  :  #800560  :  Silver License", badgeText: nil, commsEnabled: (text: true, call: true)),
                ])
        ]
    }()
    
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
