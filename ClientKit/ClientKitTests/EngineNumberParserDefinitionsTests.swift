//
//  EngineNumberParserDefinitionsTests.swift
//  ClientKit
//
//  Created by KGWH78 on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import ClientKit
@testable import MPOLKit

class EngineNumberParserDefinitionsTests: XCTestCase {
    
    func testThatEngineNumberParsesSuccessfully() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123"
        
        // When
        let results = try! parser.parseString(query: query)
        let engineNumber = results[EngineNumberParserDefinition.engineNumberKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(engineNumber, expectedResult)
    }
    
    func testThatEngineNumberParsesSuccessfullyWhenPrefixedWithSpace() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = " ABC123"
        
        // When
        let results = try! parser.parseString(query: query)
        let engineNumber = results[EngineNumberParserDefinition.engineNumberKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(engineNumber, expectedResult)
    }
    
    func testThatEngineNumberParsesSuccessfullyWhenSuffixedWithSpace() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123 "
        
        // When
        let results = try! parser.parseString(query: query)
        let engineNumber = results[EngineNumberParserDefinition.engineNumberKey]
        
        // Then
        let expectedResult = "ABC123"
        XCTAssertEqual(engineNumber, expectedResult)
    }
    
    func testThatEngineNumberParsesSuccessfullyWhenMaximumLengthIsEntered() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC123456"
        
        // When
        let results = try! parser.parseString(query: query)
        let engineNumber = results[EngineNumberParserDefinition.engineNumberKey]
        
        // Then
        let expectedResult = "ABC123456"
        XCTAssertEqual(engineNumber, expectedResult)
    }
    
    func testThatEngineNumberParsesSuccessfullyWhenMinimumLengthIsEntered() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "AB"
        
        // When
        let results = try! parser.parseString(query: query)
        let engineNumber = results[EngineNumberParserDefinition.engineNumberKey]
        
        // Then
        let expectedResult = "AB"
        XCTAssertEqual(engineNumber, expectedResult)
    }
    
    func testThatItThrowsInvalidLengthErrorWhenExceedingMaximumLength() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "ABC1234567" // 10 Characters
        
        // When
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) in
            
            // Then
            guard case EngineNumberParserError.invalidLength(let engineNumber, let requiredLengthRange) = error else {
                return XCTFail()
            }
            
            
            let expectedEngineNumber = "ABC1234567"
            let expectedLengthRange   = 2...9
            
            XCTAssertEqual(engineNumber, expectedEngineNumber)
            XCTAssertEqual(requiredLengthRange, expectedLengthRange)
        }
    }
    
    func testThatItThrowsInvalidLengthErrorWhenMinimumLengthIsNotReached() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
        let parser = QueryParser(parserDefinition: definition)
        let query = "A" // 1 Character
        
        // When
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) in
            
            // Then
            guard case EngineNumberParserError.invalidLength(_, _) = error else {
                return XCTFail()
            }
        }
    }
    
    func testThatItThrowsInvalidErrorWhenNonAlphanumericsCharacterIsEntered() {
        // Given
        let definition = EngineNumberParserDefinition(range: 2...9)
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
