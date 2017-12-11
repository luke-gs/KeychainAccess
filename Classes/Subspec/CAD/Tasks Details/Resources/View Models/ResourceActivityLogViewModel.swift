//
//  ResourceActivityLogViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceActivityLogViewModel: CADFormCollectionViewModel<ActivityLogItemViewModel>, TaskDetailsViewModel {
   
    /// The identifier for this resource
    open let callsign: String
    
    public init(callsign: String) {
        self.callsign = callsign
        super.init()
        loadData()
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return ResourceActivityLogViewController(viewModel: self)
    }
    
    open func reloadFromModel() {
        loadData()
    }

    open func loadData() {
        guard let resource = CADStateManager.shared.resourcesById[callsign] else { return }
        guard let activityLog = resource.activityLog else { return }

        sections = []
        
        let activityLogItemsViewModels = activityLog.map { item in
            return ActivityLogItemViewModel(dotFillColor: item.color,
                                            dotStrokeColor: .clear,
                                            timestamp: item.timestampString,
                                            title: item.title,
                                            subtitle: item.description)
            }.sorted { return $0.timestamp > $1.timestamp }
        
        sections.append(CADFormCollectionSectionViewModel(title: "READ", items: activityLogItemsViewModels))
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


}
