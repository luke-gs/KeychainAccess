//
//  TemplateManagerTests.swift
//  MPOLKitTests
//
//  Created by Kara Valentine on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import PromiseKit
@testable import MPOLKit

public class TemplateManagerTests: XCTestCase {

    static let testKey = "unittest"
    var handler: TemplateHandler<UserDefaultsDataSource> = TemplateHandler<UserDefaultsDataSource>(source: UserDefaultsDataSource(sourceKey: testKey))

    public override func setUp() {
        handler = TemplateHandler<UserDefaultsDataSource>(source: UserDefaultsDataSource(sourceKey: TemplateManagerTests.testKey))
    }

    public override class func tearDown() {
        let handler = TemplateHandler<UserDefaultsDataSource>(source: UserDefaultsDataSource(sourceKey: TemplateManagerTests.testKey))
        handler.source.retrieve().then { result in
            result?.forEach { template in
                handler.source.delete(template: template)
            }
        }.always {}
    }

    func testStoreRetrieveTemplate() {
        // Arrange
        let template = TextTemplate(name: "name", description: "desc", value: "value")
        let expect = expectation(description: "Retrieval works.")

        // Act
        handler.source.store(template: template)

        // Assert
        handler.source.retrieve().then { result in
            XCTAssert(result?.contains(template) ?? false)
            expect.fulfill()
            return AnyPromise(Promise<Void>())
        }.always {}

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testDeleteTemplate() {
        // Arrange
        let template = TextTemplate(name: "name", description: "desc", value: "value")
        let expect = expectation(description: "Deleting templates works.")
        handler.source.store(template: template)

        // Act
        handler.source.delete(template: template)

        // Assert
        handler.source.retrieve().then { result in
            XCTAssertFalse(result?.contains(template) ?? true)
            expect.fulfill()
            return AnyPromise(Promise<Void>())
            }.always {}

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testDecodeTemplates() {
        // Arrange
        let template = TextTemplate(name: "name", description: "desc", value: "value")
        let expect = expectation(description: "Encoding and decoding works.")
        handler.source.store(template: template) // encode and store

        // Act - retrieve and decode
        handler = TemplateHandler<UserDefaultsDataSource>(source: UserDefaultsDataSource(sourceKey: TemplateManagerTests.testKey))

        // Assert
        handler.source.retrieve().then { result in
            if let templateResult = result?.filter({ filterTemplate in filterTemplate.id == template.id }), !templateResult.isEmpty {
                let first = templateResult.first!
                XCTAssert(first.id == template.id)
                XCTAssert(first.name == template.name)
                XCTAssert(first.description == template.description)
                XCTAssert(first.value == template.value)
                XCTAssert(first.timestamp == template.timestamp)
                expect.fulfill()
                return AnyPromise(Promise<Void>())
            }
            XCTFail()
            return AnyPromise(Promise<Void>())

        }.always {}

        waitForExpectations(timeout: 5, handler: nil)
    }
}
