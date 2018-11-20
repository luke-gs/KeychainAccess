//
//  BroadcastOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

open class BroadcastOverviewViewModel: TaskDetailsOverviewViewModel {

    open var addressText: String?

    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let broadcast = model as? CADBroadcastType else { return }

        // Only show map if we have a location
        if broadcast.location?.coordinate != nil {
            let mapViewModel = BroadcastOverviewMapViewModel()
            mapViewModel.reloadFromModel(broadcast)
            self.mapViewModel = mapViewModel
        } else {
            mapViewModel = nil
        }

        var overviewItems: [FormItem] = []

        if let location = broadcast.location {
            let locationItem = AddressFormItem()
                .styleIdentifier(PublicSafetyKitStyler.addressLinkStyle)
                .title(StringSizing(string: NSLocalizedString("Broadcast Location", comment: "")))
                .subtitle(StringSizing(string: location.displayText))
                .selectionAction(AddressNavigationSelectionAction(addressNavigatable: location))
                .width(.column(1))
            overviewItems.append(locationItem)
        }

        overviewItems += [
            ValueFormItem()
                .title("Broadcast Number")
                .value(broadcast.identifier)
                .width(.column(3)),
            ValueFormItem()
                .title("Type")
                .value(broadcast.type.title)
                .width(.column(2)),
            ValueFormItem()
                .title("Created")
                .value(broadcast.createdAtString ?? "Unknown")
                .width(.column(3)),
            ValueFormItem()
                .title("Broadcast Details")
                .value(broadcast.lastUpdated?.elapsedTimeIntervalForHuman() ?? broadcast.createdAtString ?? "")
                .width(.column(2))
        ]

        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: overviewItems
            ),
            CADFormCollectionSectionViewModel(title: "Broadcast Details",
                                              items: [
                                                ValueFormItem()
                                                    .value(broadcast.details)
                                                    .width(.column(1))
                                                ])
        ]
    }

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
}
