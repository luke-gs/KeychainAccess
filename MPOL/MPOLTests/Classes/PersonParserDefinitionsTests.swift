//
//  PersonParserDefinitionsTests.swift
//  ClientKit
//
//  Created by Herli Halim on 6/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import ClientKit

class PersonParserDefinitionsTests: XCTestCase {
    
    let personDefinitions = PersonParserDefinition()
    
    func testTokeniser() {

        let cases = [
            (query: "Scott, Tony M 33-45", expectedResults: ["Scott", "Tony", "M", "33-45"]),
            (query: "Scott Tony M 33-45", expectedResults: ["Scott", "Tony", "M", "33-45"]),
            (query: "Scott,Tony M 33-45", expectedResults: ["Scott", "Tony", "M", "33-45"]),
            (query: "Scott Tony M 16/01/1990 33-45", expectedResults: ["Scott", "Tony", "M", "16/01/1990", "33-45"]),
            (query: "Scott", expectedResults: ["Scott"]),
            (query: "scott tony 33-45", expectedResults: ["scott", "tony", "33-45"]),
            (query: "scott tony 42", expectedResults: ["scott", "tony", "42"]),
            (query: "scott tony m", expectedResults: ["scott", "tony", "m"]),
            (query: "scott, tony", expectedResults: ["scott", "tony"]),
            (query: "scott,tony", expectedResults: ["scott", "tony"]),
            (query: "Van Den Berg, Matthew, 33-45 F", expectedResults: ["Van Den Berg", "Matthew", "33-45", "F"]),
            (query: "Van Den Berg,", expectedResults: ["Van Den Berg"])
        ]
        
        for testCase in cases {
            let tokens = personDefinitions.tokensFrom(query: testCase.query)
            XCTAssertEqual(tokens, testCase.expectedResults)
        }
    }

}
