//
//  IncidentNarrativeViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentNarrativeViewModel: NarrativeViewModel {
    
    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let incident = model as? CADIncidentDetailsType else { return }

        let activityLogItemsViewModels = incident.narrative.map { item in
            return ActivityLogItemViewModel(dotFillColor: item.color,
                                     dotStrokeColor: .clear,
                                     timestamp: item.timestamp,
                                     title: item.title,
                                     subtitle: item.description)
            }.sorted { return $0.timestamp > $1.timestamp }
        
        sections = sortedSectionsByDate(from: activityLogItemsViewModels)
    }
}
