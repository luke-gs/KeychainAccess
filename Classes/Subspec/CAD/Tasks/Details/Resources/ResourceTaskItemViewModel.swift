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
    
    open var resource: CADResourceType?
    
    public init(callsign: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, subtitleText: nil)

        if callsign == CADStateManager.shared.currentResource?.callsign {
            self.navTitle = NSLocalizedString("My call sign", comment: "")
        } else {
            self.navTitle = NSLocalizedString("Resource details", comment: "")
        }

        self.compactNavTitle = itemName

        self.viewModels = [
            ResourceOverviewViewModel(identifier: callsign),
            ResourceOfficerListViewModel(callsign: callsign),
            ResourceActivityLogViewModel(callsign: callsign)
        ]
    }
    
    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    public convenience init(resource: CADResourceType) {
        self.init(
            callsign: resource.callsign,
            iconImage: resource.status.icon,
            iconTintColor: resource.status.iconColors.icon,
            color: resource.status.iconColors.background,
            statusText: resource.status.title,
            itemName: [resource.callsign, resource.officerCountString].joined())
        self.resource = resource
    }

    open override func reloadFromModel() {
        if let resource = resource {
            iconImage = resource.status.icon
            iconTintColor = resource.status.iconColors.icon
            color = resource.status.iconColors.background
            statusText = resource.status.title
            itemName = [resource.callsign, resource.officerCountString].joined()

            viewModels.forEach {
                $0.reloadFromModel()
            }
        }
    }

    override open func didTapTaskStatus() {
        if let resource = resource, allowChangeResourceStatus() {
            delegate?.present(TaskItemScreen.resourceStatus(initialStatus: resource.status, incident: nil))
        }
    }

    open override func allowChangeResourceStatus() -> Bool {
        // If this resource is our booked on callsign and we have an incident, allow edit
        if let currentResource = CADStateManager.shared.currentResource, resource == currentResource,
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
