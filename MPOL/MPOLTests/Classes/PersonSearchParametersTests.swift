//
//  PersonSearchParametersTests.swift
//  MPOL
//
//  Created by KGWH78 on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import PS_Core

class PersonSearchParametersTests: XCTestCase {
    
    func testThatItCreatesSearchParametersWithFamilyNameSuccessfully() {
        // Given
        let familyName = "Halim"
        
        // When
        let search = PersonSearchParameters(familyName: familyName)
        
        // Then
        let expectedResult = "Halim"
        let actualResult   = search.parameters["familyName"] as! String
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testThatItCreatesSearchParametersSuccessfully() {
        // Given
        let familyName  = "Halim"
        let givenName   = "Herli"
        let middleNames = "Harem Harembe Junior Random Text"
        let gender      = "Female"
        let dateOfBirth = "16/01/1990"
        
        // When
        let search = PersonSearchParameters(familyName:  familyName,
                                            givenName:   givenName,
                                            middleNames: middleNames,
                                            gender:      gender,
                                            dateOfBirth: dateOfBirth)
        
        // Then
        let actualResults   = search.parameters as! [String: String]
        let expectedResults = [
            "familyName":   "Halim",
            "givenName":    "Herli",
            "middleNames":  "Harem Harembe Junior Random Text",
            "gender":       "Female",
            "dateOfBirth":  "1990-01-16"
        ]
        
        XCTAssertEqual(actualResults, expectedResults)
    }

    func testThatItCreatesSearchParametersWithOptionalDayDate() {
        // Given
        let familyName  = "Halim"
        let dateOfBirth = "01/1990"

        // When
        let search = PersonSearchParameters(familyName:  familyName,
                                            givenName:   nil,
                                            middleNames: nil,
                                            gender:      nil,
                                            dateOfBirth: dateOfBirth)

        // Then
        let actualResults   = search.parameters as! [String: String]
        let expectedResults = [
            "familyName":   "Halim",
            "dateOfBirth":  "1990-01"
        ]

        XCTAssertEqual(actualResults, expectedResults)
    }

    func testThatItCreatesSearchParametersWithOnlyYearDate() {
        // Given
        let familyName  = "Halim"
        let dateOfBirth = "1990"

        // When
        let search = PersonSearchParameters(familyName:  familyName,
                                            givenName:   nil,
                                            middleNames: nil,
                                            gender:      nil,
                                            dateOfBirth: dateOfBirth)

        // Then
        let actualResults   = search.parameters as! [String: String]
        let expectedResults = [
            "familyName":   "Halim",
            "dateOfBirth":  "1990"
        ]

        XCTAssertEqual(actualResults, expectedResults)
    }
    
}
