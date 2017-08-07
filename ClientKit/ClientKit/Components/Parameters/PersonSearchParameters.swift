//
//  PersonSearchParameters.swift
//  ClientKit
//
//  Created Herli Halim on 4/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Wrap


public class PersonSearchParameters: EntitySearchRequest<Person> {
    
    public init(familyName: String, givenName: String? = nil, middleNames: String? = nil, gender: String? = nil, dateOfBirth: String? = nil) {
        
        let parameterisable = SearchParameters(familyName: familyName, givenName: givenName, middleNames: middleNames, gender: gender, dateOfBirth: dateOfBirth)
        
        super.init(parameters: parameterisable.parameters)
    }
    
    private struct SearchParameters: Parameterisable {
        
        public let familyName: String
        public let givenName: String?
        public let middleNames: String?
        public let gender: String?
        public let dateOfBirth: String?
        
        public init(familyName: String, givenName: String? = nil, middleNames: String? = nil, gender: String? = nil, dateOfBirth: String? = nil) {
            self.familyName  = familyName
            self.givenName   = givenName
            self.middleNames = middleNames
            self.gender      = gender
            self.dateOfBirth = dateOfBirth
        }
        
        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }
}



