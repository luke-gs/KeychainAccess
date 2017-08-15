//
//  PersonSearchParametersTests.swift
//  ClientKit
//
//  Created by KGWH78 on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import ClientKit

class PersonSearchParametersTests: XCTestCase {
    
    func testThatItCreatesSearchParametersWithFamilyNameSuccessfully() {
        // Given
        let familyName = "Halim"
        
        // When
        let search = PersonSearchParameters(familyName: familyName)
        
        // Then
        let expectedResult = "Halim"
        let actualResult = search.parameters["familyName"] as! String
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testThatItCreatesSearchParametersSuccessfully() {
        // Given
        let familyName  = "Halim"
        let givenName   = "Herli"
        let middleNames = "Harem Harembe"
        let gender      = "Female"
        let dateOfBirth = "16/01/1990"
        
        // When
        let search = PersonSearchParameters(familyName: familyName,
                                            givenName: givenName,
                                            middleNames: middleNames,
                                            gender: gender,
                                            dateOfBirth: dateOfBirth)
        
        // Then
        let actualResults = search.parameters as! [String: String]
        let expectedResults = [
            "familyName":   "Halim",
            "givenName":    "Herli",
            "middleNames":  "Harem Harembe",
            "gender":       "Female",
            "dateOfBirth":  "16/01/1990"
            
            
        ]
        XCTAssertEqual(actualResults, expectedResults)
    }
    
}
