//
//  ResourceActivityLogViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceActivityLogViewModel: DatedActivityLogViewModel, TaskDetailsViewModel {
    
    open private(set) var resource: CADResourceType?
    
    /// Create the view controller for this view model
    open func createViewController() -> TaskDetailsViewController {
        return ResourceActivityLogViewController(viewModel: self)
    }
    
    open func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let resource = model as? CADResourceType else { return }
        self.resource = resource
        
        let activityLogItemsViewModels = resource.activityLog.map { item in
            return ActivityLogItemViewModel(dotFillColor: item.color,
                                            dotStrokeColor: .clear,
                                            timestamp: item.timestamp,
                                            title: item.title,
                                            subtitle: item.description)
            }.sorted { return $0.timestamp > $1.timestamp }
        
        sections = sortedSectionsByDate(from: activityLogItemsViewModels)
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Activity Log", comment: "Activity Log sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Activity Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }

    open override func allowCreate() -> Bool {
        // Only allow adding activity log entries if our resource
        return CADStateManager.shared.currentResource?.callsign == resource?.callsign
    }
}

