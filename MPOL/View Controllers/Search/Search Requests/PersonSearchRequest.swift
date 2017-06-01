//
//  PersonSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

private let statesKey      = "states"
private let genderKey      = "gender"
private let searchTypeKey  = "searchType"
private let ageRangeMinKey = "ageRangeMin"
private let ageRangeMaxKey = "ageRangeMax"


@objc(MPLPersonSearchRequest)
class PersonSearchRequest: SearchRequest {
    
    override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
}
