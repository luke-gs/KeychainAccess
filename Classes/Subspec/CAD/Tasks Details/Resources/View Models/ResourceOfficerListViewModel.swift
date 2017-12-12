//
//  ResourceOfficerListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewModel: CADFormCollectionViewModel<ResourceOfficerViewModel>, TaskDetailsViewModel {
    
    /// The identifier for this resource
    open let callsign: String
    
    public init(callsign: String) {
        self.callsign = callsign
        super.init()
        loadData()
    }

    /// Create the view controller for this view model
    open func createViewController() -> TaskDetailsViewController {
        let vc = ResourceOfficerListViewController(viewModel: self)
        delegate = vc
        return vc
    }
    
    open func reloadFromModel() {
        loadData()
    }

    open func loadData() {
        guard let resource = CADStateManager.shared.resourcesById[callsign] else { return }
        
        let officers = CADStateManager.shared.officersForResource(callsign: callsign)
        
        let officerViewModels = officers.map { officer in
            return ResourceOfficerViewModel(officer: officer, resource: resource)
        }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "\(officers.count) Officers", items: officerViewModels)
        ]
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
    
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }

}
