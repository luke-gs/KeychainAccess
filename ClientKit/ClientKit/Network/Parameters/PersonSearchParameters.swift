//
//  PersonSearchParameters.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Wrap

public struct PersonSearchParameters: Parameterisable {
    
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
    
    public var parameters: [String: Any] {
        return try! wrap(self)
    }
}
