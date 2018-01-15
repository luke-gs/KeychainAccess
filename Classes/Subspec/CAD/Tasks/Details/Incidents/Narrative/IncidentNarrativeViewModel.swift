//
//  IncidentNarrativeViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentNarrativeViewModel: CADFormCollectionViewModel<ActivityLogItemViewModel>, TaskDetailsViewModel {
    
    /// The identifier for this incident
    open let incidentNumber: String
    
    public init(incidentNumber: String) {
        self.incidentNumber = incidentNumber
        super.init()
        loadData()
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> TaskDetailsViewController {
        return IncidentNarrativeViewController(viewModel: self)
    }
    
    open func reloadFromModel() {
        loadData()
    }

    open func loadData() {
        guard let incident = CADStateManager.shared.incidentsById[incidentNumber] else { return }

        let activityLogItemsViewModels = incident.narrative.map { item in
            return ActivityLogItemViewModel(dotFillColor: item.color,
                                     dotStrokeColor: .clear,
                                     timestamp: item.timestampString,
                                     title: item.title,
                                     subtitle: item.description)
            }.sorted { return $0.timestamp > $1.timestamp }
        
        sections = [CADFormCollectionSectionViewModel(title: "READ", items: activityLogItemsViewModels)]
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Narrative", comment: "Narrative sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Activity Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }
    

}
