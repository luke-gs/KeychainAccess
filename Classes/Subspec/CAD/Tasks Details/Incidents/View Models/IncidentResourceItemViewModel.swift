//
//  IncidentResourceItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentResourceItemViewModel {
    
    open let callsign: String
    open let title: String
    open let subtitle: String
    open let icon: UIImage?
    open let officers: [ResourceOfficerViewModel]
    
    init(callsign: String, title: String, subtitle: String, icon: UIImage?, officers: [ResourceOfficerViewModel]) {
        self.callsign = callsign
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.officers = officers
    }
}
