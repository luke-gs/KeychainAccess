//
//  PatrolOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

open class PatrolOverviewViewModel: TaskDetailsOverviewViewModel {

    public override init() {
        super.init()
        mapViewModel = PatrolOverviewMapViewModel()
    }

    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let patrol = model as? CADPatrolType else { return }
        (mapViewModel as? PatrolOverviewMapViewModel)?.reloadFromModel(patrol)
        location = patrol.location

        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: "Patrol Location",
                                                                              value: location?.displayText,
                                                                              width: .column(1),
                                                                              selectAction: { [unowned self] cell in
                                                                                self.presentAddressPopover(from: cell)
                                                                              },
                                                                              isAddress: true),

                                                TaskDetailsOverviewItemViewModel(title: "Patrol number",
                                                                              value: patrol.identifier,
                                                                              width: .column(3)),

                                                TaskDetailsOverviewItemViewModel(title: "Type",
                                                                              value: patrol.type,
                                                                              width: .column(3)),

                                                TaskDetailsOverviewItemViewModel(title: "Subtype",
                                                                              value: patrol.subtype,
                                                                              width: .column(3)),

                                                TaskDetailsOverviewItemViewModel(title: "Created",
                                                                              value: patrol.createdAtString ?? "",
                                                                              width: .column(3)),

                                                TaskDetailsOverviewItemViewModel(title: "Last Updated",
                                                                              value: patrol.lastUpdated?.elapsedTimeIntervalForHuman() ?? "",
                                                                              width: .column(3))
                                                ]),

            CADFormCollectionSectionViewModel(title: "Patrol Details",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: nil,
                                                                              value: patrol.details,
                                                                              width: .column(1))
                                                ])
        ]
    }

    /// The title to use in the navigation bar
    open override func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
}
