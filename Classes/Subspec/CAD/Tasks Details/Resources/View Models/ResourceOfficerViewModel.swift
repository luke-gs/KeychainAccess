//
//  ResourceOfficerViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceOfficerViewModel {
    
    public var title: String
    public var subtitle: String
    public var badgeText: String?
    public var commsEnabled: (text: Bool, call: Bool)
    
    public init(title: String, subtitle: String, badgeText: String?, commsEnabled: (text: Bool, call: Bool)) {
        self.title = title
        self.subtitle = subtitle
        self.badgeText = badgeText
        self.commsEnabled = commsEnabled
    }
    
    convenience public init(officer: SyncDetailsOfficer, resource: SyncDetailsResource?) {
        self.init(title: officer.displayName,
                  subtitle: [officer.rank, officer.payrollIdDisplayString, officer.licenceTypeId]
                    .joined(separator: "  •  "),
                  badgeText: resource?.driver == officer.payrollId ? "DRIVER": nil,
                  commsEnabled: (false, officer.contactNumber != nil))
    }
}
