//
//  IncidentOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import MapKit

open class IncidentOverviewViewModel: TaskDetailsOverviewViewModel {

    public override init() {
        super.init()
        mapViewModel = IncidentOverviewMapViewModel()
    }

    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let incident = model as? CADIncidentType else { return }
        (mapViewModel as? IncidentOverviewMapViewModel)?.reloadFromModel(incident)

        var taskDetailsOverviewItems: [FormItem] = []

        if let location = incident.location {
            let addressItem = AddressFormItem()
                .styleIdentifier(PublicSafetyKitStyler.addressLinkStyle)
                .title(StringSizing(string: NSLocalizedString("Incident Location", comment: ""), font: UIFont.preferredFont(forTextStyle: .subheadline)))
                .subtitle(StringSizing(string: location.fullAddress, font: UIFont.preferredFont(forTextStyle: .subheadline)))
                .selectionAction(AddressNavigationSelectionAction(addressNavigatable: location))
                .width(.column(1))

            taskDetailsOverviewItems.append(addressItem)
        }

        taskDetailsOverviewItems += [
            ValueFormItem()
                .title(NSLocalizedString("Priority", comment: ""))
                .value(incident.grade.title)
                .width(.column(3)),
            ValueFormItem()
                .title(NSLocalizedString("Incident Number", comment: ""))
                .value(incident.incidentNumber)
                .width(.column(3))
        ]

        if let secondaryCode = incident.secondaryCode {
            // show Secondary Code only if it has a code
            taskDetailsOverviewItems.append(ValueFormItem()
                .title(NSLocalizedString("Secondary Code", comment: ""))
                .value(secondaryCode)
                .width(.column(3))
            )
        }

        if let patrolGroup = incident.patrolGroup {
            taskDetailsOverviewItems.append(
                ValueFormItem()
                    .title(NSLocalizedString("Patrol Area", comment: ""))
                    .value(patrolGroup)
                    .width(.column(3))
            )
        }

        taskDetailsOverviewItems += [
            ValueFormItem()
                .title(NSLocalizedString("Created", comment: ""))
                .value(incident.createdAtString ?? NSLocalizedString("Unknown", comment: ""))
                .width(.column(3)),
            ValueFormItem()
                .title(NSLocalizedString("Updated", comment: ""))
                .value(incident.lastUpdated?.elapsedTimeIntervalForHuman() ?? incident.createdAt?.elapsedTimeIntervalForHuman() ?? NSLocalizedString("Unknown", comment: ""))
                .width(.column(3))
        ]

        sections = [
            CADFormCollectionSectionViewModel(title: NSLocalizedString("Overview", comment: ""),
                                              items: taskDetailsOverviewItems,
                                              preventCollapse: true),

            CADFormCollectionSectionViewModel(title: NSLocalizedString("Informant Details", comment: ""),
                                              items: [
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Name", comment: ""))
                                                    .value(incident.informant?.fullName ?? NSLocalizedString("Unknown", comment: ""))
                                                    .width(.column(3)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Contact Number", comment: ""))
                                                    .value(incident.informant?.primaryPhone ?? NSLocalizedString("Unknown", comment: ""))
                                                    .width(.column(3))
                ],
                                              preventCollapse: true),
            CADFormCollectionSectionViewModel(title: NSLocalizedString("Incident Details", comment: ""),
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
