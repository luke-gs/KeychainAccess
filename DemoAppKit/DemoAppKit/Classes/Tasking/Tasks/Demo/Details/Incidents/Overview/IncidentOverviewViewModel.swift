//
//  IncidentOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import PublicSafetyKit

open class IncidentOverviewViewModel: TaskDetailsOverviewViewModel {

    public override init() {
        super.init()
        mapViewModel = IncidentOverviewMapViewModel()
    }

    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let incident = model as? CADIncidentType else { return }
        (mapViewModel as? IncidentOverviewMapViewModel)?.reloadFromModel(incident)

        var taskDetailsOverviewItems: [FormItem] = []

        if let location = incident.location, let context = delegate as? UIViewController {
            let addressItem = AddressFormItem()
                .styleIdentifier(PublicSafetyKitStyler.detailLinkStyle)
                .subtitle(StringSizing(string: location.fullAddress, font: UIFont.preferredFont(forTextStyle: .subheadline)))
                .navigatable(location, presentationContext: context)
                .width(.column(1))

            taskDetailsOverviewItems.append(addressItem)
        }

        taskDetailsOverviewItems += [
            ValueFormItem()
                .title("Priority")
                .value(incident.grade.title)
                .width(.column(3)),
            ValueFormItem()
                .title("Incident Number")
                .value(incident.incidentNumber)
                .width(.column(3))
        ]

        if let secondaryCode = incident.secondaryCode {
            // show Secondary Code only if it has a code
            taskDetailsOverviewItems.append(ValueFormItem()
                .title("Secondary Code")
                .value(secondaryCode)
                .width(.column(3))
            )
        }

        if let patrolGroup = incident.patrolGroup {
            taskDetailsOverviewItems.append(
                ValueFormItem()
                    .title("Patrol Area")
                    .value(patrolGroup)
                    .width(.column(3))
            )
        }

        taskDetailsOverviewItems += [
            ValueFormItem()
                .title("Created")
                .value(incident.createdAtString ?? "Unknown")
                .width(.column(3)),
            ValueFormItem()
                .title("Updated")
                .value(incident.lastUpdated?.elapsedTimeIntervalForHuman() ?? incident.createdAt?.elapsedTimeIntervalForHuman() ?? "Unknown")
                .width(.column(3))
        ]

        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: taskDetailsOverviewItems,
                                              preventCollapse: true),

            CADFormCollectionSectionViewModel(title: "Informant Details",
                                              items: [
                                                ValueFormItem()
                                                    .title("Name")
                                                    .value(incident.informant?.fullName ?? "Unknown")
                                                    .width(.column(3)),
                                                ValueFormItem()
                                                    .title("Contact Number")
                                                    .value(incident.informant?.primaryPhone ?? "Unknown")
                                                    .width(.column(3))
                ],
                                              preventCollapse: true),
            CADFormCollectionSectionViewModel(title: "Incident Details",
                                              items: [
                                                ValueFormItem()
                                                    .value(incident.details)
                                                    .width(.column(1))
                ],
                                              preventCollapse: true)
        ]
    }

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }

}
