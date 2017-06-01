//
//  PersonOptionDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class PersonSearchDataSource: SearchDataSource {

    @NSCopying private var personSearchRequest: PersonSearchRequest = PersonSearchRequest() {
        didSet {
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return personSearchRequest
        }
        set {
            guard let newRequest = newValue as? PersonSearchRequest else {
                fatalError("You must not set a request type which is inconsistent with the `requestType` class property")
            }
            personSearchRequest = newRequest
        }
    }
    
    override func supports(_ request: SearchRequest) -> Bool {
        return request is PersonSearchRequest
    }
    
    override func reset(withSearchText searchText: String?) {
        personSearchRequest = PersonSearchRequest(searchText: searchText)
    }
    
    override var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
}
