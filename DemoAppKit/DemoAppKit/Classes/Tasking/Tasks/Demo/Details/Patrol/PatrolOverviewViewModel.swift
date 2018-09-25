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

        var overviewItems: [FormItem] = []

        if let location = patrol.location, let context = delegate as? UIViewController {
            let addressItem = NavigationFormItemFactory.addressNavigationFormItem(address: location, title: "Patrol Location", context: context)
            overviewItems.append(addressItem)
        }

        overviewItems += [
            ValueFormItem()
                .title("Patrol Number")
                .value(patrol.identifier)
                .width(.column(3)),
            ValueFormItem()
                .title("Type")
                .value(patrol.type)
                .width(.column(3)),
            ValueFormItem()
                .title("Subtype")
                .value(patrol.subtype)
                .width(.column(3)),
            ValueFormItem()
                .title("Created")
                .value(patrol.createdAtString ?? "Unknown")
                .width(.column(3)),
            ValueFormItem()
                .title("Last Updated")
                .value(patrol.lastUpdated?.elapsedTimeIntervalForHuman() ?? patrol.createdAtString ?? "Unknown")
                .width(.column(3))
        ]

        sections = [
            CADFormCollectionSectionViewModel(title: "Overview", items: overviewItems),
            CADFormCollectionSectionViewModel(title: "Patrol Details",
                                              items: [
                                                ValueFormItem()
                                                    .value(patrol.details)
                                                    .width(.column(1))
                ])
        ]
    }
    
    /// The title to use in the navigation bar
    open override func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
}
