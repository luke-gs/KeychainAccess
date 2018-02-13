//
//  ResourceTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceTaskItemViewModel: TaskItemViewModel {
    
    open private(set) var resource: SyncDetailsResource?
    
    public init(callsign: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName)

        if callsign == CADStateManager.shared.currentResource?.callsign {
            self.navTitle = NSLocalizedString("My call sign", comment: "")
        } else {
            self.navTitle = NSLocalizedString("Resource details", comment: "")
        }

        self.compactNavTitle = itemName

        self.viewModels = [
            ResourceOverviewViewModel(callsign: callsign),
            ResourceOfficerListViewModel(callsign: callsign),
            ResourceActivityLogViewModel(callsign: callsign)
        ]
    }
    
    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    public convenience init(resource: SyncDetailsResource) {
        self.init(
            callsign: resource.callsign,
            iconImage: resource.statusType.icon,
            iconTintColor: resource.statusType.iconColors.icon,
            color: resource.statusType.iconColors.background,
            statusText: resource.statusType.title,
            itemName: [resource.callsign, resource.officerCountString].joined())
        self.resource = resource
    }

    override open func didTapTaskStatus() {
        if allowChangeResourceStatus() {
            let callsignStatus = CADStateManager.shared.currentResource?.statusType ?? ClientModelTypes.resourceStatus.defaultCase
            let incidentItems = ClientModelTypes.resourceStatus.incidentCases.map {
                return ManageCallsignStatusItemViewModel($0)
            }
            let sections = [CADFormCollectionSectionViewModel(title: "", items: incidentItems)]
            let viewModel = CallsignStatusViewModel(sections: sections, selectedStatus: callsignStatus, incident: nil)
            viewModel.showsCompactHorizontal = false
            let viewController = viewModel.createViewController()

            delegate?.presentStatusSelector(viewController: viewController)
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

}
