//
//  LocationSearchDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class LocationSearchDataSource: SearchDataSource {
    
    @NSCopying private var locationSearchRequest = LocationSearchRequest() {
        didSet {
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return locationSearchRequest
        }
        set {
            guard let newRequest = newValue as? LocationSearchRequest, supports(newRequest) else {
                fatalError("You must not set a request the data source doesn't support.")
            }
            locationSearchRequest = newRequest
        }
    }
    
    override func supports(_ request: SearchRequest) -> Bool {
        return request is LocationSearchRequest
    }
    
    override func reset(withSearchText searchText: String?) {
        locationSearchRequest = LocationSearchRequest(searchText: searchText)
    }
    
    override var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }
    
}

