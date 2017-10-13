//
//  FormBuilderTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class FormBuilderTests: XCTestCase {

    /// MARK: - Basic form builder tests

    func testThatItInstantiatesWithCorrectDefaults() {
        // Given
        let builder = FormBuilder()

        // When
        let title = builder.title
        let forceLinearLayout = builder.forceLinearLayout
        let itemsCount = builder.formItems.count

        // Expected
        XCTAssertNil(title)
        XCTAssertFalse(forceLinearLayout)
        XCTAssertEqual(itemsCount, 0)
    }
    
    func testThatItAddsAnItem() {
        // Given
        let builder = FormBuilder()
        let item = SubtitleFormItem()

        // When
        builder.add(item)

        // Then
        XCTAssertEqual(builder.formItems.count, 1)
        XCTAssert(builder.formItems.first === item)
    }

    func testThatItAddsAnItemWithOperator() {
        // Given
        let builder = FormBuilder()
        let item = SubtitleFormItem()

        // When
        builder += item

        // Then
        XCTAssertEqual(builder.formItems.count, 1)
        XCTAssert(builder.formItems.first === item)
    }

    func testThatItAddsMultipleItems() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")

        // When
        builder.add([item1, item2])

        // Then
        XCTAssertEqual(builder.formItems.count, 2)
        XCTAssert(builder.formItems.first === item1)
        XCTAssert(builder.formItems.last === item2)
    }

    func testThatItAddsMultipleItemsWithOperator() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")

        // When
        builder += [item1, item2]

        // Then
        XCTAssertEqual(builder.formItems.count, 2)
        XCTAssert(builder.formItems.first === item1)
        XCTAssert(builder.formItems.last === item2)
    }

    func testThatItRemovesAnItem() {
        // Given
        let builder = FormBuilder()
        let item = SubtitleFormItem()
        builder.add(item)

        // When
        builder.remove(item)

        // Then
        XCTAssertEqual(builder.formItems.count, 0)
    }

    func testThatItRemovesAnItemWithOperator() {
        // Given
        let builder = FormBuilder()
        let item = SubtitleFormItem()
        builder.add(item)

        // When
        builder -= item

        // Then
        XCTAssertEqual(builder.formItems.count, 0)
    }

    func testThatItRemovesMultipleItems() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")
        builder.add([item1, item2])

        // When
        builder.remove([item1, item2])

        // Then
        XCTAssertEqual(builder.formItems.count, 0)
    }

    func testThatItRemovesMultipleItemsWithOperator() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")
        builder.add([item1, item2])

        // When
        builder -= [item1, item2]

        // Then
        XCTAssertEqual(builder.formItems.count, 0)
    }

    func testThatItRemovesAllItems() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")
        builder.add([item1, item2])

        // When
        builder.removeAll()

        // Then
        XCTAssertEqual(builder.formItems.count, 0)
    }

    func testThatItDoesNotRemoveItemThatIsNotInTheBuilder() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        builder.add(item1)

        // When
        let item2 = SubtitleFormItem().title("Goodbye")
        builder.remove(item2)

        // Then
        XCTAssertEqual(builder.formItems.count, 1)
    }


    /// MARK: - Sections generation

    func testThatItGeneratesASectionWithOnlyBaseItems() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")
        builder.add([item1, item2])

        // When
        let sections = builder.generateSections()

        // Then
        let mainSection = sections.first
        XCTAssertEqual(sections.count, 1)
        XCTAssertNil(mainSection!.formHeader)
        XCTAssertNil(mainSection!.formFooter)
        XCTAssertEqual(mainSection!.formItems.count, 2)
    }

    func testThatItGeneratesASectionWithBaseItemsAndHeader() {
        // Given
        let builder = FormBuilder()
        let header = HeaderFormItem().text("Header")
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")
        builder.add([header, item1, item2])

        // When
        let sections = builder.generateSections()

        // Then
        let mainSection = sections.first
        XCTAssertEqual(sections.count, 1)
        XCTAssertNotNil(mainSection!.formHeader)
        XCTAssertNil(mainSection!.formFooter)
        XCTAssertEqual(mainSection!.formItems.count, 2)
    }

    func testThatItGeneratesASectionWithBaseItemsAndFooter() {
        // Given
        let builder = FormBuilder()
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")
        let footer = FooterFormItem().text("Footer")
        builder.add([item1, item2, footer])

        // When
        let sections = builder.generateSections()

        // Then
        let mainSection = sections.first
        XCTAssertEqual(sections.count, 1)
        XCTAssertNil(mainSection!.formHeader)
        XCTAssertNotNil(mainSection!.formFooter)
        XCTAssertEqual(mainSection!.formItems.count, 2)
    }

    func testThatItGeneratesASectionWithHeaderAndFooter() {
        // Given
        let builder = FormBuilder()
        let header = HeaderFormItem().text("Header")
        let footer = FooterFormItem().text("Footer")
        builder.add([header, footer])

        // When
        let sections = builder.generateSections()

        // Then
        let mainSection = sections.first
        XCTAssertEqual(sections.count, 1)
        XCTAssertNotNil(mainSection!.formHeader)
        XCTAssertNotNil(mainSection!.formFooter)
        XCTAssertEqual(mainSection!.formItems.count, 0)
    }

    func testThatItGeneratesASectionWithBaseItemsAndHeaderAndFooter() {
        // Given
        let builder = FormBuilder()
        let header = HeaderFormItem().text("Header")
        let item1 = SubtitleFormItem().title("Hello")
        let item2 = SubtitleFormItem().title("Goodbye")
        let footer = FooterFormItem().text("Footer")
        builder.add([header, item1, item2, footer])

        // When
        let sections = builder.generateSections()

        // Then
        let mainSection = sections.first
        XCTAssertEqual(sections.count, 1)
        XCTAssertNotNil(mainSection!.formHeader)
        XCTAssertNotNil(mainSection!.formFooter)
        XCTAssertEqual(mainSection!.formItems.count, 2)
    }

    func testThatItGeneratesSectionsScenarioOne() {
        // Section 1
        //    Header
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Header
        //    Item1, Item2, Item3
        //    Footer

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [header1, item1_1, item1_2, footer1]

        let header2 = HeaderFormItem()
        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        let footer2 = FooterFormItem()
        builder += [header2, item2_1, item2_2, item2_3, footer2]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: header2, formItems: [item2_1, item2_2, item2_3], formFooter: footer2)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioTwo() {
        // Section 1
        //    Header
        //    Item1, Item2
        //
        // Section 2
        //    Header
        //    Item1, Item2, Item3
        //    Footer

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        builder += [header1, item1_1, item1_2]

        let header2 = HeaderFormItem()
        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        let footer2 = FooterFormItem()
        builder += [header2, item2_1, item2_2, item2_3, footer2]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: nil)
        let expectedSecondSection = FormSection(formHeader: header2, formItems: [item2_1, item2_2, item2_3], formFooter: footer2)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioThree() {
        // Section 1
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Header
        //    Item1, Item2, Item3
        //    Footer

        // Given
        let builder = FormBuilder()

        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [item1_1, item1_2, footer1]

        let header2 = HeaderFormItem()
        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        let footer2 = FooterFormItem()
        builder += [header2, item2_1, item2_2, item2_3, footer2]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: nil, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: header2, formItems: [item2_1, item2_2, item2_3], formFooter: footer2)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioFour() {
        // Section 1
        //    Item1, Item2
        //
        // Section 2
        //    Header
        //    Item1, Item2, Item3
        //    Footer

        // Given
        let builder = FormBuilder()

        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        builder += [item1_1, item1_2]

        let header2 = HeaderFormItem()
        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        let footer2 = FooterFormItem()
        builder += [header2, item2_1, item2_2, item2_3, footer2]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: nil, formItems: [item1_1, item1_2], formFooter: nil)
        let expectedSecondSection = FormSection(formHeader: header2, formItems: [item2_1, item2_2, item2_3], formFooter: footer2)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioFive() {
        // Section 1
        //    Header
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Item1, Item2, Item3
        //    Footer

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [header1, item1_1, item1_2, footer1]

        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        let footer2 = FooterFormItem()
        builder += [item2_1, item2_2, item2_3, footer2]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: nil, formItems: [item2_1, item2_2, item2_3], formFooter: footer2)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioSix() {
        // Section 1
        //    Footer
        //
        // Section 2
        //    Footer

        // Given
        let builder = FormBuilder()

        let footer1 = FooterFormItem()
        let footer2 = FooterFormItem()

        builder += footer1
        builder += footer2

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: nil, formItems: [], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: nil, formItems: [], formFooter: footer2)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioSeven() {
        // Section 1
        //    Header
        //
        // Section 2
        //    Header

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let header2 = HeaderFormItem()

        builder += header1
        builder += header2

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [], formFooter: nil)
        let expectedSecondSection = FormSection(formHeader: header2, formItems: [], formFooter: nil)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioEight() {
        // Section 1
        //    Header
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Header
        //    Item1, Item2, Item3

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [header1, item1_1, item1_2, footer1]

        let header2 = HeaderFormItem()
        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        builder += [header2, item2_1, item2_2, item2_3]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: header2, formItems: [item2_1, item2_2, item2_3], formFooter: nil)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioNine() {
        // Section 1
        //    Header
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Item1, Item2, Item3

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [header1, item1_1, item1_2, footer1]

        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        builder += [item2_1, item2_2, item2_3]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: nil, formItems: [item2_1, item2_2, item2_3], formFooter: nil)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
    }

    func testThatItGeneratesSectionsScenarioTen() {
        // Section 1
        //    Header
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Header
        //    Item1, Item2, Item3
        //    Footer
        //
        // Section 2
        //    Header
        //    Item1
        //    Footer

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [header1, item1_1, item1_2, footer1]

        let header2 = HeaderFormItem()
        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        let footer2 = FooterFormItem()
        builder += [header2, item2_1, item2_2, item2_3, footer2]

        let header3 = HeaderFormItem()
        let item3_1 = SubtitleFormItem()
        let footer3 = FooterFormItem()
        builder += [header3, item3_1, footer3]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]
        let thirdSection = sections[2]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: header2, formItems: [item2_1, item2_2, item2_3], formFooter: footer2)
        let expectedThirdSection = FormSection(formHeader: header3, formItems: [item3_1], formFooter: footer3)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
        XCTAssertEqual(thirdSection, expectedThirdSection)
    }

    func testThatItGeneratesSectionsScenarioEleven() {
        // Section 1
        //    Header
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Item1, Item2, Item3
        //    Footer
        //
        // Section 2
        //    Header
        //    Item1
        //    Footer

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [header1, item1_1, item1_2, footer1]

        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        let footer2 = FooterFormItem()
        builder += [item2_1, item2_2, item2_3, footer2]

        let header3 = HeaderFormItem()
        let item3_1 = SubtitleFormItem()
        let footer3 = FooterFormItem()
        builder += [header3, item3_1, footer3]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]
        let thirdSection = sections[2]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: nil, formItems: [item2_1, item2_2, item2_3], formFooter: footer2)
        let expectedThirdSection = FormSection(formHeader: header3, formItems: [item3_1], formFooter: footer3)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
        XCTAssertEqual(thirdSection, expectedThirdSection)
    }

    func testThatItGeneratesSectionsScenarioTwelve() {
        // Section 1
        //    Header
        //    Item1, Item2
        //    Footer
        //
        // Section 2
        //    Item1, Item2, Item3
        //
        // Section 2
        //    Header
        //    Item1
        //    Footer

        // Given
        let builder = FormBuilder()

        let header1 = HeaderFormItem()
        let item1_1 = SubtitleFormItem()
        let item1_2 = SubtitleFormItem()
        let footer1 = FooterFormItem()
        builder += [header1, item1_1, item1_2, footer1]

        let item2_1 = SubtitleFormItem()
        let item2_2 = SubtitleFormItem()
        let item2_3 = SubtitleFormItem()
        builder += [item2_1, item2_2, item2_3]

        let header3 = HeaderFormItem()
        let item3_1 = SubtitleFormItem()
        let footer3 = FooterFormItem()
        builder += [header3, item3_1, footer3]

        // When
        let sections = builder.generateSections()
        let firstSection = sections[0]
        let secondSection = sections[1]
        let thirdSection = sections[2]

        // Then
        let expectedFirstSection = FormSection(formHeader: header1, formItems: [item1_1, item1_2], formFooter: footer1)
        let expectedSecondSection = FormSection(formHeader: nil, formItems: [item2_1, item2_2, item2_3], formFooter: nil)
        let expectedThirdSection = FormSection(formHeader: header3, formItems: [item3_1], formFooter: footer3)

        XCTAssertEqual(firstSection, expectedFirstSection)
        XCTAssertEqual(secondSection, expectedSecondSection)
        XCTAssertEqual(thirdSection, expectedThirdSection)
    }

}
