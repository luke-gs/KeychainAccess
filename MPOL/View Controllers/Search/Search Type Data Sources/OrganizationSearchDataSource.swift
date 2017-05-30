//
//  OrganizationSearchDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class OrganizationSearchDataSource: SearchDataSource {

    override class func supports(_ request: SearchRequest) -> Bool {
        return request is OrganizationSearchRequest
    }
    
    private var organizationSearchRequest = OrganizationSearchRequest() {
        didSet {
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return organizationSearchRequest
        }
        set {
            guard let newRequest = newValue as? OrganizationSearchRequest else {
                fatalError("You must not set a request type which is inconsistent with the `requestType` class property")
            }
            organizationSearchRequest = newRequest
        }
    }
    
    override var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
}
