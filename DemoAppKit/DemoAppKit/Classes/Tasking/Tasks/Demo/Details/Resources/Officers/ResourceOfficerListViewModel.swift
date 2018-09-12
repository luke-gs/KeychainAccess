//
//  ResourceOfficerListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewModel: CADFormCollectionViewModel<ResourceOfficerViewModel>, TaskDetailsViewModel {
    
    /// Create the view controller for this view model
    open func createViewController() -> TaskDetailsViewController {
        return ResourceOfficerListViewController(viewModel: self)
    }
    
    open func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let resource = model as? CADResourceType else { return }
        
        let officers = CADStateManager.shared.officersForResource(callsign: resource.callsign)
        
        let officerViewModels = officers.map { officer in
            return ResourceOfficerViewModel(officer: officer, resource: resource)
        }
        
        let title = String.localizedStringWithFormat(NSLocalizedString("%d Officer(s)", comment: ""), officers.count)
        sections = [
            CADFormCollectionSectionViewModel(title: title, items: officerViewModels)
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
