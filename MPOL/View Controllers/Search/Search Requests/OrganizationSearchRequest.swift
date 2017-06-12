//
//  OrganizationSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

@objc(MPLOrganizationSearchRequest)
class OrganizationSearchRequest: SearchRequest {
    
    override class var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
}
