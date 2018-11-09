//
//  BroadcastNarrativeViewModel.swift
//  DemoAppKit
//
//  Created by Campbell Graham on 6/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class BroadcastNarrativeViewModel: NarrativeViewModel {

    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let broadcast = model as? CADBroadcastDetailsType else { return }

        let activityLogItemsViewModels = broadcast.narrative.map { item in
            return ActivityLogItemViewModel(dotFillColor: item.color,
                                            dotStrokeColor: .clear,
                                            timestamp: item.timestamp,
                                            title: item.title,
                                            subtitle: item.description)
            }.sorted { return $0.timestamp > $1.timestamp }

        sections = sortedSectionsByDate(from: activityLogItemsViewModels)
    }
}
