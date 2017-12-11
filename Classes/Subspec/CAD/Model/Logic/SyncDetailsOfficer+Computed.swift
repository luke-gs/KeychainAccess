//
//  SyncDetailsOfficer+Computed.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension SyncDetailsOfficer {
    
    open var displayName: String {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.middleName = middleName
        nameComponents.familyName = lastName
        return OfficerDetailsResponse.nameFormatter.string(from: nameComponents)
    }
    
    open static var nameFormatter: PersonNameComponentsFormatter = {
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.style = .medium
        return nameFormatter
    }()
    
    open var payrollIdDisplayString: String? {
        if let payrollId = payrollId {
            return "#\(payrollId)"
        }
        return nil
    }
    
    open var initials: String {
        return "\(firstName.prefix(1))\(lastName.prefix(1))"
    }

}
