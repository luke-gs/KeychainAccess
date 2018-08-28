//
//  QueryParserTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

private class TestParser: QueryParserDefinition {
    var tokenDefinitions: [QueryTokenDefinition] = [
        QueryTokenDefinition(key: "key", required: true, typeCheck: { (string) -> Bool in
            return true
        }),
        QueryTokenDefinition(key: "key2", required: true, typeCheck: { (string) -> Bool in
            return true
        })
    ]
    func tokensFrom(query: String) -> [String] {
        return ["value", "value2"]
    }
}

private class EmptyTestParser: QueryParserDefinition {
    var tokenDefinitions: [QueryTokenDefinition] = []
    func tokensFrom(query: String) -> [String] {
        return ["value", "value2"]
    }
}

private class InvalidTestParser: QueryParserDefinition {
    var tokenDefinitions: [QueryTokenDefinition] = [
        QueryTokenDefinition(key: "key", required: true, typeCheck: { (string) -> Bool in
            return true
        }, validate: { (string, count, dict) in
            
        }),
        QueryTokenDefinition(key: "key2", required: true, typeCheck: { (string) -> Bool in
            return true
        }, validate: { (string, count, dict) in
            throw ParsingError.notParsable
        })
    ]
    func tokensFrom(query: String) -> [String] {
        return ["value", "value2"]
    }
}

private class MultiTokenTestParser: QueryParserDefinition {
    var tokenDefinitions: [QueryTokenDefinition] = [
        QueryTokenDefinition(key: "key", required: true, typeCheck: { (string) -> Bool in
            return true
        }),
        QueryTokenDefinition(key: "key", required: true, typeCheck: { (string) -> Bool in
            return true
        })
    ]
    func tokensFrom(query: String) -> [String] {
        return ["value", "value2"]
    }
}

class QueryParserTests: XCTestCase {

    let validDict = ["key": "value", "key2": "value2"]
    let invalidDict = ["key3": "value3", "key4": "value4"]

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testParserEquality() {
        let testParser = TestParser()
        let parser = QueryParser(parserDefinition: testParser)
        XCTAssertEqual(validDict, try! parser.parseString(query: "key"))
    }

    func testEmptyParserThrows() {
        let testParser = EmptyTestParser()
        let parser = QueryParser(parserDefinition: testParser)
        XCTAssertThrowsError(try parser.parseString(query: "key"))
    }

    func testParserThrows() {
        let testParser = InvalidTestParser()
        let parser = QueryParser(parserDefinition: testParser)
        XCTAssertThrowsError(try parser.parseString(query: "key"))
    }

    func testMultiTokenParserThrows() {
        let testParser = MultiTokenTestParser()
        let parser = QueryParser(parserDefinition: testParser)
        XCTAssertThrowsError(try parser.parseString(query: "key"))
    }
}

