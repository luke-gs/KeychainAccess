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
    open let officers: [ResourceOfficerViewModel]
    
    init(title: String, subtitle: String, officers: [ResourceOfficerViewModel]) {
        self.title = title
        self.subtitle = subtitle
        self.officers = officers
    }
}
