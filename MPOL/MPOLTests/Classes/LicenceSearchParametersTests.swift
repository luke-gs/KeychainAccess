//
//  LicenceSearchParametersTests.swift
//  MPOL
//
//  Created by KGWH78 on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import DemoAppKit

class LicenceSearchParametersTests: XCTestCase {
    
    func testThatItCreatesSearchParametersWithLicenceSuccessfully() {
        // Given
        let licence = "099898778"
        
        // When
        let search = LicenceSearchParameters(licenceNumber: licence)
        
        // Then
        let expectedResult = "099898778"
        let actualResult = search.parameters["licenceNumber"] as! String
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
}
