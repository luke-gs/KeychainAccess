//
//  TemplateManagerTests.swift
//  MPOLKitTests
//
//  Created by Kara Valentine on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

public class TemplateManagerTests: XCTestCase {

    override public func setUp() {
        TemplateManager.shared.add(template: "template 1", forKey: "test1")
        TemplateManager.shared.add(template: "template 2", forKey: "test2")
    }

    override public func tearDown() {
        TemplateManager.shared.removeAll()
    }

    func testGetTemplate() {
        // Act
        let template = TemplateManager.shared.template(forKey: "test1")

        // Assert
        XCTAssertEqual(template, "template 1")
    }

    func testGetAllTemplates() {
        // Act
        let templates = TemplateManager.shared.allTemplates()

        // Assert
        XCTAssertEqual(["template 1", "template 2"], templates)
    }

    func testAddTemplate() {
        // Arrange
        let templateCount = TemplateManager.shared.allTemplates().count

        // Act
        TemplateManager.shared.add(template: "template 3", forKey: "test3")

        // Assert
        XCTAssertEqual(templateCount, TemplateManager.shared.allTemplates().count - 1)
    }

    func testEditTemplate() {
        // Arrange
        let originalTemplate = TemplateManager.shared.template(forKey: "test1")

        // Act
        TemplateManager.shared.edit(template: "modified template 1", forKey: "test1")

        // Assert
        XCTAssertNotEqual(originalTemplate, TemplateManager.shared.template(forKey: "test1"))
    }

    func testRemoveTemplate() {
        // Act
        TemplateManager.shared.remove(templateForKey: "test2")

        // Assert
        XCTAssertNil(TemplateManager.shared.template(forKey: "test2"))
    }
}
