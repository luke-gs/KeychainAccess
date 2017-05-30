//
//  OrganizationSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

@objc(MPLOrganizationSearchRequest)
class OrganizationSearchRequest: SearchRequest {
    
    override class var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
    
    // MARK: - Initializers
    
    required init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
}
