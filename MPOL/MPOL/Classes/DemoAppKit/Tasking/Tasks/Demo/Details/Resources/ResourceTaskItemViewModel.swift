//
//  ResourceTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import PublicSafetyKit

open class ResourceTaskItemViewModel: TaskItemViewModel {

    /// The optional summary loaded during construction
    open var resourceSummary: CADResourceType?

    // MARK: - Init

    public init(callsign: String) {
        super.init(taskItemIdentifier: callsign)

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
        return resourceDetails ?? resourceSummary
    }

    // MARK: - Methods

    open override func createViewModels() -> [TaskDetailsViewModel] {
        return [ResourceOverviewViewModel(),
                ResourceOfficerListViewModel(),
                ResourceActivityLogViewModel()]
    }

    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    open override func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        // Use map to convert resource to CADTaskListItemModelType and keep compiler happy
        return CADStateManager.shared.getResourceDetails(identifier: taskItemIdentifier).map { [weak self] resource in
            self?.lastDetailLoadTime = Date()
            return resource
        }
    }

    open override func reloadFromModel() {
        guard let resource = self.resourceDetailsOrSummary else { return }

        iconImage = resource.status.icon
        iconTintColor = resource.status.iconColors.icon
        color = resource.status.iconColors.background
        statusText = resource.status.title
        itemName = [resource.callsign, resource.officerCountString].joined()
        compactNavTitle = itemName
        compactTitle = statusText
        compactSubtitle = subtitleText

        viewModels.forEach {
            $0.reloadFromModel(resource)
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

}
