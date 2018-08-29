//
//  SymaticVersionComparerTests.swift
//  MPOLKitTests
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest


class SemanticVersionTest: XCTestCase {

    func testInitialisationWithValidFormat() {
        // Given
        let version1 = SemanticVersion("1")
        let version2 = SemanticVersion("5.6.12")
        let version3 = SemanticVersion("1.21.3-Alpha")
        let version4 = SemanticVersion("3.3.5-Alpha.5+B298")
        let version5 = SemanticVersion("3.3.5-x.1.0+B145")

        // Then
        XCTAssertNotNil(version1, "Initialisation of version1 should not have failed as it meets the semantic version format requirements")
        XCTAssertNotNil(version2, "Initialisation of version2 should not have failed as it meets the semantic version format requirements")
        XCTAssertNotNil(version3, "Initialisation of version3 should not have failed as it meets the semantic version format requirements")
        XCTAssertNotNil(version4, "Initialisation of version4 should not have failed as it meets the semantic version format requirements")
        XCTAssertNotNil(version5, "Initialisation of version5 should not have failed as it meets the semantic version format requirements")

    }

    func testInitialisationWithInvalidFormat() {
        // Given
        let version1 = SemanticVersion("1-2-2")
        let version2 = SemanticVersion("a.b.c")
        let version3 = SemanticVersion("3.4.2.x6.b4.b8")
        let version4 = SemanticVersion("3.3.5-Alpha-1")
        let version5 = SemanticVersion("3.3.5+B2+B5")
        let nilVersion = SemanticVersion(nil)

        // Then
        XCTAssertNil(version1, "major, minor, and patch cannot be seperated by hyphens")
        XCTAssertNil(version2, "major, minor, and patch must be represented by numbers")
        XCTAssertNil(version3, "prerelease version elements cannot contain both numbers and letters")
        XCTAssertNil(version4, "prerelease version elements must be separated by decimal points '.'")
        XCTAssertNil(version5, "there may only be one build meta data element")
        XCTAssertNil(nilVersion, "passing in nil will result in nil")
    }

    func testAppendNonsuppliedValues() {
        // Given
        let version1 = SemanticVersion("1")

        // Then
        XCTAssertNotNil(version1, "Initialisation of version should not have failed as it meets the semantic version format requirements")
        XCTAssert(version1?.minor == "0")
        XCTAssert(version1?.patch == "0")
        XCTAssert(version1?.prerelease == nil)
        XCTAssert(version1?.build == nil)

        // Given
        let version2 = SemanticVersion("1.1-alpha")

        // Then
        XCTAssertNotNil(version2, "Initialisation of version should not have failed as it meets the semantic version format requirements")
        XCTAssert(version2?.major == "1")
        XCTAssert(version2?.minor == "1")
        XCTAssert(version2?.patch == "0")
        XCTAssert(version2?.prerelease == "alpha")
        XCTAssert(version2?.build == nil)

        // Given
        let version3 = SemanticVersion("2.0+B45")

        // Then
        XCTAssertNotNil(version3, "Initialisation of version should not have failed as it meets the semantic version format requirements")
        XCTAssert(version3?.major == "2")
        XCTAssert(version3?.minor == "0")
        XCTAssert(version3?.patch == "0")
        XCTAssert(version3?.prerelease == nil)
        XCTAssert(version3?.build == "B45")
    }

    func testEqualToComparision() {
        // Given
        let version1 = SemanticVersion("1")
        let version2 = SemanticVersion("1.0.0")

        // Then
        XCTAssert(version1! == version2!)

        // Given
        let version3 = SemanticVersion("2")
        let version4 = SemanticVersion("2.1")

        // Then
        XCTAssert(version3! != version4!)

        // Given
        let version5 = SemanticVersion("2.1-Alpha")
        let version6 = SemanticVersion("2.1-Beta")

        // Then
        XCTAssert(version5! != version6!)

        // Given
        let version7 = SemanticVersion("3.1+B45")
        let version8 = SemanticVersion("3.1+B46")

        // Then
        XCTAssert(version7! == version8!)
    }

    func testLessThanComparision() {
        // Given
        let version1 = SemanticVersion("1.2.1")
        let version2 = SemanticVersion("1.2.2")
        let version3 = SemanticVersion("3")

        // Then
        XCTAssert(version1! < version2!)
        XCTAssert(version2! > version1!)
        XCTAssert(version1! < version3!)

        // Given
        let version4 = SemanticVersion("3.0.1")
        let version5 = SemanticVersion("4.0.1")

        // Then
        XCTAssert(version4! < version5!)

        // Given
        let version6 = SemanticVersion("11.4")
        let version7 = SemanticVersion("11.6")

        // Then
        XCTAssert(version6! < version7!)
    }

    func testPrereleaseLessThanComparision() {
        // Given
        let version1 = SemanticVersion("1.2.3-A.B.C")
        let version2 = SemanticVersion("1.2.3-B")

        // Then
        XCTAssert(version1! < version2!)

        // Given
        let version3 = SemanticVersion("2.0-1.4")
        let version4 = SemanticVersion("2.0-2.1")

        // Then
        XCTAssert(version3! < version4!)

        // Given
        let version5 = SemanticVersion("1.1.1-1")
        let version6 = SemanticVersion("1.1.1-A")

        // Then
        XCTAssert(version5! < version6!)
    }

}
