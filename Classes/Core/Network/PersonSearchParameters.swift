//
//  PersonSearchQuery.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/*
 http://api.mpol.solutions/source/entity/person/search?surname=Smith&givenName=John&middleNames=Andrew%20Robert&gender=M&dateOfBirth=1983-10-29
 */

public struct PersonSearchQuery {
    
    public let surname: String
    public let givenName: String?
    public let middleNames: String?
    
    public let gender: String?
    public let dateOfBirth: String?
    
    public init(surname: String, givenName: String? = nil, middleNames: String? = nil, gender: String? = nil, dateOfBirth: String? = nil) {
        self.surname = surname
        self.givenName = givenName
        self.middleNames = middleNames
        self.gender = gender
        self.dateOfBirth = dateOfBirth
    }
}
