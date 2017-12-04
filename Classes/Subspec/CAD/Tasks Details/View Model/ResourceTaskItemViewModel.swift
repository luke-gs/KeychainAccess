//
//  ResourceTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceTaskItemViewModel: TaskItemViewModel {
    
    public init(iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor, statusText: String?, itemName: String?, lastUpdated: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, lastUpdated: lastUpdated)
        
        self.viewModels = [
            ResourceOfficerListViewModel(),
            ResourceActivityLogViewModel()
        ]
    }

    public convenience init(resource: SyncDetailsResource) {
        self.init(
            iconImage: resource.status.icon,
            iconTintColor: resource.status.iconColors.icon,
            color: resource.status.iconColors.background,
            statusText: resource.status.title,
            itemName: [resource.callsign, resource.officerCountString].removeNils().joined(separator: " "),
            lastUpdated: resource.lastUpdated.elapsedTimeIntervalForHuman())
    }
}
