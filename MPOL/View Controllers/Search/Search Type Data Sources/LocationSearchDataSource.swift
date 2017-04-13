//
//  LocationSearchDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class LocationSearchDataSource: SearchDataSource {
    
    override class var requestType: SearchRequest.Type {
        return LocationSearchRequest.self
    }
    
    private var locationSearchRequest = LocationSearchRequest() {
        didSet {
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return locationSearchRequest
        }
        set {
            guard let newRequest = newValue as? LocationSearchRequest else {
                fatalError("You must not set a request type which is inconsistent with the `requestType` class property")
            }
            locationSearchRequest = newRequest
        }
    }
    
    override var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }
    
}

