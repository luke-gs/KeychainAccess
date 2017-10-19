//
//  FormSectionTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class FormSectionTests: XCTestCase {

    func testThatItCreates() {
        // Given
        let header = HeaderFormItem()
        let items: [FormItem] = [SubtitleFormItem(), SubtitleFormItem()]
        let footer = FooterFormItem()

        // When
        let section = FormSection(formHeader: header, formItems: items, formFooter: footer)

        // Then
        XCTAssert(section.formHeader === header)
        XCTAssert(section.formFooter === footer)
        XCTAssert(section.formItems.elementsEqual(items, by: { $0 === $1 }))
    }

    func testThatItEquals() {
        // Given
        let header = HeaderFormItem()
        let item1 = SubtitleFormItem()
        let item2 = SubtitleFormItem()
        let footer = FooterFormItem()

        // When
        let section1 = FormSection(formHeader: header, formItems: [item1, item2], formFooter: footer)
        let section2 = FormSection(formHeader: header, formItems: [item1, item2], formFooter: footer)

        // Then
        XCTAssertEqual(section1, section2)
    }

    func testThatItIsNotEqualWhenNoHeader() {
        // Given
        let header = HeaderFormItem()
        let item1 = SubtitleFormItem()
        let item2 = SubtitleFormItem()
        let footer = FooterFormItem()

        // When
        let section1 = FormSection(formHeader: header, formItems: [item1, item2], formFooter: footer)
        let section2 = FormSection(formHeader: nil, formItems: [item1, item2], formFooter: footer)

        // Then
        XCTAssertNotEqual(section1, section2)
    }

    func testThatItIsNotEqualWhenNoFooter() {
        // Given
        let header = HeaderFormItem()
        let item1 = SubtitleFormItem()
        let item2 = SubtitleFormItem()
        let footer = FooterFormItem()

        // When
        let section1 = FormSection(formHeader: header, formItems: [item1, item2], formFooter: footer)
        let section2 = FormSection(formHeader: header, formItems: [item1, item2], formFooter: nil)

        // Then
        XCTAssertNotEqual(section1, section2)
    }

    func testThatItIsNotEqualWhenItemsAreDifferent() {
        // Given
        let header = HeaderFormItem()
        let item1 = SubtitleFormItem()
        let item2 = SubtitleFormItem()
        let footer = FooterFormItem()

        // When
        let section1 = FormSection(formHeader: header, formItems: [item1, item2], formFooter: footer)
        let section2 = FormSection(formHeader: nil, formItems: [item2, item1], formFooter: nil)

        // Then
        XCTAssertNotEqual(section1, section2)
    }

    func testThatItGetsItemWithSubscript() {
        // Given
        let item1: FormItem = SubtitleFormItem()
        let item2: FormItem = ValueFormItem()
        let section = FormSection(formHeader: nil, formItems: [item1, item2], formFooter: nil)

        // When
        let expectedItem1 = section[0]
        let expectedItem2 = section[1]

        // Then
        XCTAssert(item1 === expectedItem1)
        XCTAssert(item2 === expectedItem2)
    }

    func testThatItGetsItemWithIndexPath() {
        // Given
        let item1: FormItem = SubtitleFormItem()
        let item2: FormItem = ValueFormItem()

        let sections = [
            FormSection(formHeader: nil, formItems: [item1, ValueFormItem()], formFooter: nil),
            FormSection(formHeader: nil, formItems: [SubtitleFormItem(), item2], formFooter: nil)
        ]

        // When
        let expectedItem1 = sections[IndexPath(item: 0, section: 0)]
        let expectedItem2 = sections[IndexPath(item: 1, section: 1)]

        // Then
        XCTAssert(item1 === expectedItem1)
        XCTAssert(item2 === expectedItem2)
    }

}
