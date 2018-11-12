//
//  IncidentResourceItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentResourceItemViewModel {

    public let callsign: String
    public let title: String
    public let subtitle: String
    public let icon: UIImage?
    public let officers: [ResourceOfficerViewModel]

    public init(callsign: String, title: String, subtitle: String, icon: UIImage?, officers: [ResourceOfficerViewModel]) {
        self.callsign = callsign
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.officers = officers
    }
}
