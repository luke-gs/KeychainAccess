//
//  URLQueryBuilderTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 20/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import MPOLKit

struct SomeParameter: Parameterisable {

    let source: String
    let name: String

    var parameters: [String : Any] {
        return ["source": source, "name": name]
    }

}

class URLQueryBuilderTests: XCTestCase {

    let builder = URLQueryBuilder()

    func testThatItWorksWithEmptyTemplateAndParameters() {

        let template = ""
        let parameters: [String: Any] = [:]

        let expectedTemplate = template
        let expectedParameters = parameters as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItWorksWithNoParametersReplacement() {
        // Template doesn't have {} as placeholder for replacement
        let template = "source"
        let parameters: [String: Any] = [:]

        let expectedTemplate = template
        let expectedParameters = parameters as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)

        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItDoesNotTryToReplaceNonPlaceholderMatchingWord() {
        // Template doesn't have {} as placeholder for replacement
        let template = "source"
        let parameters: [String: Any] = ["source": "fnc"]

        let expectedTemplate = template
        let expectedParameters = parameters as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItCorrectlyReplaceValues() {
        let template = "{source}"
        let parameters: [String: Any] = ["source": "fnc"]

        let expectedTemplate = "fnc"
        let expectedParameters = [:] as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItCouldHandleMultipleReplacements() {
        let template = "{source}/{entity}/{name}"
        let parameters: [String: Any] = ["source": "fnc", "entity": "person", "name": "Herli"]

        let expectedTemplate = "fnc/person/Herli"
        let expectedParameters = [:] as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItCouldHandleMultipleReplacementsWithTemplateRemainderAtTheEnd() {
        let template = "{source}/{entity}/{name}/whynot"
        let parameters: [String: Any] = ["source": "fnc", "entity": "person", "name": "Herli"]

        let expectedTemplate = "fnc/person/Herli/whynot"
        let expectedParameters = [:] as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItCouldHandleMultipleReplacementsWithTemplateRemainderInTheMiddle() {
        let template = "{source}/{entity}/index/{name}/whynot"
        let parameters: [String: Any] = ["source": "fnc", "entity": "person", "name": "Herli"]

        let expectedTemplate = "fnc/person/index/Herli/whynot"
        let expectedParameters = [:] as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItCouldHandleMultipleReplacementsWithParameterRemainders() {
        let template = "{source}/{entity}/{name}/whynot"
        let parameters: [String: Any] = ["source": "fnc", "entity": "person", "name": "Herli", "notMatching": "coolstory"]

        let expectedTemplate = "fnc/person/Herli/whynot"
        let expectedParameters = ["notMatching": "coolstory"] as NSDictionary

        let result = try! self.builder.urlPathWith(template: template, parameters: parameters)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)

    }

    func testThatItThrowsWhenTemplateReplacementNotFound() {

        let template = "{source}/{entity}/{ok}"
        let parameters: [String: Any] = ["source": "fnc", "name": "Herli", "notMatching": "coolstory"]

        XCTAssertThrowsError(
            try self.builder.urlPathWith(template: template, parameters: parameters)
        )

    }

    func testThatParameterisableIsCorrect() {

        let template = "{source}/entity/{name}"
        let parameter = SomeParameter(source: "fnc", name: "Herli")

        let expectedTemplate = "fnc/entity/Herli"
        let expectedParameters: NSDictionary = [:]

        let result = try! self.builder.urlPathWith(template: template, parameters: parameter)
        XCTAssertEqual(result.path, expectedTemplate)
        XCTAssertEqual(result.parameters as NSDictionary, expectedParameters)
    }

}
