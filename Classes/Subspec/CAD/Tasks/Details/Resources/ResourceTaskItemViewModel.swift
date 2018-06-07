//
//  ResourceTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class ResourceTaskItemViewModel: TaskItemViewModel {
    
    /// The optional summary loaded during construction
    open var resourceSummary: CADResourceType?

    // MARK: - Init

    public init(callsign: String) {
        super.init(taskItemIdentifier: callsign,
                   viewModels: [ResourceOverviewViewModel(),
                                ResourceOfficerListViewModel(),
                                ResourceActivityLogViewModel()
            ])

        if callsign == CADStateManager.shared.currentResource?.callsign {
            self.navTitle = NSLocalizedString("My call sign", comment: "")
        } else {
            self.navTitle = NSLocalizedString("Resource details", comment: "")
        }

        // Load the summary if available
        resourceSummary = CADStateManager.shared.resourcesById[callsign]
        if resourceSummary != nil {
            reloadFromModel()
        }
    }
    
    // MARK: - Generated properties

    /// Return the loaded details
    open var resourceDetails: CADResourceType? {
        return taskItemDetails as? CADResourceType
    }

    /// Return the loaded details or the summary if available
    open var resourceDetailsOrSummary: CADResourceType? {
        return taskItemDetails as? CADResourceType ?? resourceSummary
    }

    // MARK: - Methods

    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    open override func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        resourceSummary = CADStateManager.shared.resourcesById[taskItemIdentifier]
        return Promise<CADTaskListItemModelType>.value(resourceSummary!)
    }

    open override func reloadFromModel() {
        let resource = self.resourceDetailsOrSummary

        iconImage = resource?.status.icon
        iconTintColor = resource?.status.iconColors.icon
        color = resource?.status.iconColors.background
        statusText = resource?.status.title
        itemName = [resource?.callsign, resource?.officerCountString].joined()
        compactNavTitle = itemName
        compactTitle = statusText
        compactSubtitle = subtitleText

        if let resourceDetails = resourceDetails {
            viewModels.forEach {
                $0.reloadFromModel(resourceDetails)
            }
        }
        super.reloadFromModel()
    }

    override open func didTapTaskStatus() {
        if let resource = resourceDetailsOrSummary, allowChangeResourceStatus() {
            delegate?.present(TaskItemScreen.resourceStatus(initialStatus: resource.status, incident: nil))
        }
    }

    open override func allowChangeResourceStatus() -> Bool {
        // If this resource is our booked on callsign and we have an incident, allow edit
        if let currentResource = CADStateManager.shared.currentResource, resourceDetailsOrSummary == currentResource,
            CADStateManager.shared.currentIncident != nil {
            return true
        }
        return false
    }

    open override func refreshTask() -> Promise<Void> {
        // TODO: Add method to CADStateManager to fetch individual resource
        return Promise<Void>()
    }
}
