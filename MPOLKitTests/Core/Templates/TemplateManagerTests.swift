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

    let template1 = Template(name: "test1", description: "The first test template.", value: "This is a test template.")
    let template2 = Template(name: "test2", description: "The second test template.", value: "This is another test template.")

    static let cachedTemplate = Template(name: "cached", description: "A cached network template.", value: "This is a cached network template.")
    static let template9 = Template(name: "test9", description: "The ninth test template.", value: "This is yet another test template.")
    static let networkTemplate = Template(name: "networktemplate", description: "A network template.", value: "This template comes from the network!")

    class DummyTemplateDelegate: TemplateDelegate {

        func storeCachedTemplates() {}

        func storeLocalTemplates() {}

        var url: URL = try! "http://google.com".asURL()

        func retrieveCachedTemplates() -> Set<Template> {
            return [cachedTemplate]
        }
        func retrieveLocalTemplates() -> Set<Template> {
            return [template9]
        }
        func retrieveNetworkTemplates() -> Promise<Set<Template>> {
            return Promise<Set<Template>> { fulfil, reject in
                fulfil([networkTemplate])
            }
        }
    }

    let delegate = DummyTemplateDelegate()

    override public func setUp() {
        TemplateManager.shared.delegate = delegate
        TemplateManager.shared.add(template: template1)
        TemplateManager.shared.add(template: template2)
    }

    override public func tearDown() {
        TemplateManager.shared.removeAll()
    }

    func testGetTemplate() {
        // Act
        let template = TemplateManager.shared.template(withName: template1.name)!

        // Assert
        XCTAssert(template.name == template1.name
            && template.description == template1.description
            && template.value == template1.value)
    }

    func testGetAllTemplates() {
        // Act
        let templates = TemplateManager.shared.allTemplates()

        // Assert
        XCTAssert(templates.isSuperset(of: [template1, template2, TemplateManagerTests.cachedTemplate, TemplateManagerTests.template9]))
    }

    func testAddTemplate() {
        // Arrange
        let templateCount = TemplateManager.shared.allTemplates().count

        // Act
        TemplateManager.shared.add(template: Template(name: "test3"))

        // Assert
        XCTAssertEqual(TemplateManager.shared.allTemplates().count, templateCount + 1)
    }

    func testEditTemplate() {
        // Arrange
        let oldTemplate = TemplateManager.shared.template(withName: template1.name)!

        // Act
        TemplateManager.shared.edit(template: Template(name: template1.name, description: "A modified description.", value: "A modified value."))

        let newTemplate = TemplateManager.shared.template(withName: template1.name)!

        // Assert
        XCTAssert(oldTemplate.name != newTemplate.name
            || oldTemplate.description != newTemplate.description
            || oldTemplate.value != newTemplate.value)
    }

    func testRemoveTemplate() {
        // Act
        TemplateManager.shared.remove(templateWithName: template1.name)

        // Assert
        XCTAssertNil(TemplateManager.shared.template(withName: template1.name))
    }
}
