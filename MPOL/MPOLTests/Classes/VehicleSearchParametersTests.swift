//
//  VehicleSearchParametersTests.swift
//  MPOL
//
//  Created by KGWH78 on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import DemoAppKit
import PS_Core

class VehicleSearchParametersTests: XCTestCase {
    
    func testThatItCreatesSearchParametersWithRegistrationSuccessfully() {
        // Given
        let registration = "PAVEL01"
        
        // When
        let search = VehicleSearchParameters(registration: registration)
        
        // Then
        let expectedResult = "PAVEL01"
        let actualResult = search.parameters["plateNumber"] as! String
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testThatItCreatesSearchParametersWithVINSuccessfully() {
        // Given
        let vin = "CALLMEMAYBEBUTDONTCALLMENOW"
        
        // When
        let search = VehicleSearchParameters(vin: vin)
        
        // Then
        let expectedResult = "CALLMEMAYBEBUTDONTCALLMENOW"
        let actualResult = search.parameters["vin"] as! String
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testThatItCreatesSearchParametersWithEngineNumberSuccessfully() {
        // Given
        let engineNumber = "TOYSTORY3HALIMEDITION"
        
        // When
        let search = VehicleSearchParameters(engineNumber: engineNumber)
        
        // Then
        let expectedResult = "TOYSTORY3HALIMEDITION"
        let actualResult = search.parameters["engineNumber"] as! String
        
        XCTAssertEqual(actualResult, expectedResult)
    }

    func testThatItCreatesSearchParametersWithExtraParametersSuccessfully() {
        // Given
        let registration = "PAVEL01"
        let vehicleType = "Car"
        let state = "VIC"

        // When
        let search = VehicleSearchParameters(registration: registration, vehicleType: vehicleType, state: state)

        // Then
        let expectedResult = "PAVEL01CarVIC"
        let actualResult = (search.parameters["plateNumber"] as! String) + (search.parameters["vehicleType"] as! String) + (search.parameters["state"] as! String)

        XCTAssertEqual(actualResult, expectedResult)
    }
}
