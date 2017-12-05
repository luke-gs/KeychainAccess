//
//  IncidentResourceItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentResourceItemViewModel {
    
    open let title: String
    open let subtitle: String
    open let icon: UIImage?
    open let officers: [ResourceOfficerViewModel]
    
    init(title: String, subtitle: String, icon: UIImage?, officers: [ResourceOfficerViewModel]) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.officers = officers
    }
}
