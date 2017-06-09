//
//  OrganizationSearchDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class OrganizationSearchDataSource: SearchDataSource {
    
    @NSCopying private var organizationSearchRequest = OrganizationSearchRequest() {
        didSet {
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return organizationSearchRequest
        }
        set {
            guard let newRequest = newValue as? OrganizationSearchRequest, supports(newRequest) else {
                fatalError("You must not set a request the data source doesn't support.")
            }
            organizationSearchRequest = newRequest
        }
    }
    
    override func supports(_ request: SearchRequest) -> Bool {
        return request is OrganizationSearchRequest
    }
    
    override func reset(withSearchText searchText: String?) {
        organizationSearchRequest = OrganizationSearchRequest(searchText: searchText)
    }
    
    override var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
}
