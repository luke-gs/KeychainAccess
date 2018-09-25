//
//  ResourceOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 5/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

open class ResourceOverviewViewModel: TaskDetailsOverviewViewModel {

    open var resource: CADResourceType?
    
    override open func createFormViewController() -> FormBuilderViewController {
        return ResourceOverviewFormViewController(viewModel: self)
    }
    
    public override init() {
        super.init()
        mapViewModel = ResourceOverviewMapViewModel()
    }


    open var currentIncidentViewModel: TasksListIncidentViewModel? {
        guard let resource = resource,
            let incidentNumber = resource.currentIncident,
            let incident = CADStateManager.shared.incidentsById[incidentNumber]
        else {
            return nil
        }
        let source = CADClientModelTypes.taskListSources.incidentCase
        return TasksListIncidentViewModel(incident: incident, source: source, showsDescription: false, showsResources: false, hasUpdates: false)
    }
    
    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let resource = model as? CADResourceType else { return }
        self.resource = resource
        (mapViewModel as? ResourceOverviewMapViewModel)?.reloadFromModel(resource)

        // Load text from manifest
        var vehicleCategoryText: String? = nil
        if let vehicleCategoryId = resource.vehicleCategoryId {
            if let entry = Manifest.shared.entry(withID: vehicleCategoryId) {
                vehicleCategoryText = entry.rawValue
            }
        }

        sections = [
            CADFormCollectionSectionViewModel(title: NSLocalizedString("Shift Details", comment: ""),
                                              items: [
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Start Time", comment: ""))
                                                    .value(resource.shiftStartString)
                                                    .width(.column(3)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Estimated End Time", comment: ""))
                                                    .value(resource.shiftEndString)
                                                    .width(.column(3)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Duration", comment: ""))
                                                    .value(resource.shiftDuration)
                                                    .width(.column(3)),
                                                ]),

            CADFormCollectionSectionViewModel(title: NSLocalizedString("Call Sign Details", comment: ""),
                                              items: [
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Type", comment: ""))
                                                    .value(resource.type.rawValue)
                                                    .width(.column(4)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Station", comment: ""))
                                                    .value(resource.station)
                                                    .width(.column(4)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Fleet ID", comment: ""))
                                                    .value(resource.serial)
                                                    .width(.column(4)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Category", comment: ""))
                                                    .value(vehicleCategoryText)
                                                    .width(.column(4)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Equipment", comment: ""))
                                                    .value(resource.equipmentListString(separator: ", "))
                                                    .width(.column(4)),
                                                ValueFormItem()
                                                    .title(NSLocalizedString("Remarks", comment: ""))
                                                    .value(resource.remarks ?? "-")
                                                    .width(.column(1)),
                                                ])
        ]
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
    
    open func respondingToHeaderTitle() -> String {
        return NSLocalizedString("Responding To", comment: "").uppercased()
    }

    open func showManageButton() -> Bool {
        if let bookOn = CADStateManager.shared.lastBookOn, bookOn.callsign == resource?.callsign {
            return true
        }
        return false
    }

    open func manageCallsign() {
        if let resource = CADStateManager.shared.currentResource {
            delegate?.present(BookOnScreen.bookOnDetailsForm(resource: resource, formSheet: true))
        }
    }
}

