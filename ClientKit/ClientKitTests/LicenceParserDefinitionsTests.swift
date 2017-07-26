//
//  LicenceParserDefinitionsTests.swift
//  ClientKit
//
//  Created by Herli Halim on 21/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import ClientKit
@testable import MPOLKit

class LicenceParserDefinitionsTests: XCTestCase {
    
    func testTokeniser() {
        
        let definition = LicenceParserDefinition(range: 1...9)
        
        let tokens = definition.tokensFrom(query: "123456789")
        let expectedResult = ["123456789"]
        
        XCTAssertEqual(tokens, expectedResult)
    }
    
    func testTokeniserWithSpacedInput() {
        let definition = LicenceParserDefinition(range: 1...9)
        
        let tokens = definition.tokensFrom(query: " 123456789 ")
        let expectedResult = ["123456789"]
        
        XCTAssertEqual(tokens, expectedResult)
    }

    func testQueryParserIntegration() {
        let range = 1...9
        let query = "123456789"
        let definition = LicenceParserDefinition(range: range)
        let parser = QueryParser(parserDefinition: definition)
        
        let tokens = try! parser.parseString(query: query)
        let expectedResult = ["licence" : query]
        XCTAssertEqual(tokens, expectedResult)

    }
    
    func testQueryParserInvalidLicenceError() {
        let range = 1...9
        let query = "12345678a"
        let definition = LicenceParserDefinition(range: range)
        let parser = QueryParser(parserDefinition: definition)

        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) -> Void in
            guard case LicenceParseError.invalidLicenceNumber = error else {
                return XCTFail()
            }
        }
    }
    
    func testQueryParserInvalidLengthError() {
        let range = 1...9
        let query = "1234567890"
        let definition = LicenceParserDefinition(range: range)
        let parser = QueryParser(parserDefinition: definition)
        
        XCTAssertThrowsError(try parser.parseString(query: query)) { (error) -> Void in
            guard case LicenceParseError.invalidLength(let errorLicence, let errorRange) = error else {
                return XCTFail()
            }
            XCTAssertEqual(errorLicence, query)
            XCTAssertEqual(errorRange, range)
        }
    }
}
