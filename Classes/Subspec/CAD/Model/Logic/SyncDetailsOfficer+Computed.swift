//
//  SyncDetailsOfficer+Computed.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension SyncDetailsOfficer {
    
    /// Concatenation of first and last name
    open var firstLastName: String {
        return [firstName, lastName].removeNils().joined(separator: " ")
    }
    
    open var payrollIdDisplayString: String? {
        if let payrollId = payrollId {
            return "#\(payrollId)"
        }
        return nil
    }

}
