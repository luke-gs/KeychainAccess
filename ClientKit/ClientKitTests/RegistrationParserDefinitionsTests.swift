//
//  RegistrationParserDefinitionsTests.swift
//  ClientKit
//
//  Created by KGWH78 on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import ClientKit
@testable import MPOLKit

class RegistrationParserDefinitionsTests: XCTestCase {
    
    func testThatRegistrationParsesSuccessfully() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123"
        
        // When
        let results = try! parser.parseString(query: query)
        let registration = results[RegistrationParserDefinition.registrationKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(registration, expectedResult)
    }
    
    func testThatRegistrationParsesSuccessfullyWhenPrefixedWithSpace() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = " ABC123"
        
        // When
        let results = try! parser.parseString(query: query)
        let registration = results[RegistrationParserDefinition.registrationKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(registration, expectedResult)
    }
    
    func testThatRegistrationParsesSuccessfullyWhenSuffixedWithSpace() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123 "
        
        // When
        let results = try! parser.parseString(query: query)
        let registration = results[RegistrationParserDefinition.registrationKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(registration, expectedResult)
    }

    func testThatRegistrationParsesSuccessfullyWhenMaximumLengthIsEntered() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123456"
        
        // When
        let results = try! parser.parseString(query: query)
        let registration = results[RegistrationParserDefinition.registrationKey]
        
        // Then
        let expectedResult = "ABC123456"
        XCTAssertEqual(registration, expectedResult)
    }
    
    func testThatRegistrationParsesSuccessfullyWhenMinimumLengthIsEntered() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "AB"
        
        // When
        let results = try! parser.parseString(query: query)
        let registration = results[RegistrationParserDefinition.registrationKey]
        
        // Then
        let expectedResult = "AB"
        XCTAssertEqual(registration, expectedResult)
    }
    
    func testThatItThrowsInvalidLengthErrorWhenExceedingMaximumLength() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC1234567" // 10 Characters
        
        // When
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) in
            
            // Then
            guard case RegistrationParserError.invalidLength(let licenceNumber, let requiredLengthRange) = error else {
                return XCTFail()
            }
            
            
            let expectedLicenceNumber = "ABC1234567"
            let expectedLengthRange   = 2...9
            
            XCTAssertEqual(licenceNumber, expectedLicenceNumber)
            XCTAssertEqual(requiredLengthRange, expectedLengthRange)
        }
    }
    
    func testThatItThrowsInvalidLengthErrorWhenMinimumLengthIsNotReached() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "A" // 1 Character
        
        // When
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) in
            
            // Then
            guard case RegistrationParserError.invalidLength(_, _) = error else {
                return XCTFail()
            }
        }
    }
 
    func testThatItThrowsInvalidErrorWhenNonAlphanumericsCharacterIsEntered() {
        // Given
        let definition = RegistrationParserDefinition(range: 2...9)
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
