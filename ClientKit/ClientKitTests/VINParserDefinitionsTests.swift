//
//  VINParserDefinitionsTests.swift
//  ClientKit
//
//  Created by KGWH78 on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import ClientKit
@testable import MPOLKit

class VINParserDefinitionsTests: XCTestCase {
 
    func testThatVINParsesSuccessfully() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123"
        
        // When
        let results = try! parser.parseString(query: query)
        let vin = results[VINParserDefinition.vinKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(vin, expectedResult)
    }
    
    func testThatVINParsesSuccessfullyWhenPrefixedWithSpace() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = " ABC123"
        
        // When
        let results = try! parser.parseString(query: query)
        let vin = results[VINParserDefinition.vinKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(vin, expectedResult)
    }
    
    func testThatVINParsesSuccessfullyWhenSuffixedWithSpace() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123 "
        
        // When
        let results = try! parser.parseString(query: query)
        let vin = results[VINParserDefinition.vinKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(vin, expectedResult)
    }
    
    func testThatVINParsesSuccessfullyWhenMaximumLengthIsEntered() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123456"
        
        // When
        let results = try! parser.parseString(query: query)
        let vin = results[VINParserDefinition.vinKey]
        
        // Then
        let expectedResult = "ABC123456"
        XCTAssertEqual(vin, expectedResult)
    }
    
    func testThatVINParsesSuccessfullyWhenMinimumLengthIsEntered() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "AB"
        
        // When
        let results = try! parser.parseString(query: query)
        let vin = results[VINParserDefinition.vinKey]
        
        // Then
        let expectedResult = "AB"
        XCTAssertEqual(vin, expectedResult)
    }
    
    func testThatItThrowsInvalidLengthErrorWhenExceedingMaximumLength() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC1234567" // 10 Characters
        
        // When
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) in
            
            // Then
            guard case VINParserError.invalidLength(let vin, let requiredLengthRange) = error else {
                return XCTFail()
            }
            
            
            let expectedVin = "ABC1234567"
            let expectedLengthRange   = 2...9
            
            XCTAssertEqual(vin, expectedVin)
            XCTAssertEqual(requiredLengthRange, expectedLengthRange)
        }
    }
    
    func testThatItThrowsInvalidLengthErrorWhenMinimumLengthIsNotReached() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "A" // 1 Character
        
        // When
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) in
            
            // Then
            guard case VINParserError.invalidLength(_, _) = error else {
                return XCTFail()
            }
        }
    }
    
    func testThatItThrowsInvalidErrorWhenNonAlphanumericsCharacterIsEntered() {
        // Given
        let definition = VINParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC@33"
        
        // When
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) in
            
            // Then
            guard case QueryParserError.typeNotFound(let token) = error else {
                return XCTFail()
            }
            
            let expectedToken = "ABC@33"
            XCTAssertEqual(token, expectedToken)
        }
    }

    
}
