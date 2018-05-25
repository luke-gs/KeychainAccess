//
//  IncidentNarrativeViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentNarrativeViewModel: DatedActivityLogViewModel, TaskDetailsViewModel {
    
    /// The identifier for this incident
    open let incidentNumber: String
    
    public init(incidentNumber: String) {
        self.incidentNumber = incidentNumber
        super.init()
        loadData()
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> TaskDetailsViewController {
        let vc = IncidentNarrativeViewController(viewModel: self)
        self.delegate = vc
        return vc
    }
    
    open func reloadFromModel() {
        loadData()
    }

    open func loadData() {
        guard let incident = CADStateManager.shared.incidentsById[incidentNumber] else { return }

        let activityLogItemsViewModels = incident.narrative.map { item in
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
