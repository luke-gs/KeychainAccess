//
//  ResourceTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceTaskItemViewModel: TaskItemViewModel {
    
    public init(callsign: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor, statusText: String?, itemName: String?, lastUpdated: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, lastUpdated: lastUpdated)
        
        self.viewModels = [
            ResourceOverviewViewModel(callsign: callsign),
            ResourceOfficerListViewModel(callsign: callsign),
            ResourceActivityLogViewModel(callsign: callsign)
        ]
    }
   
}
