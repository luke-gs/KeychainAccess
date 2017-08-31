//
//  ThemeManagerTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ThemeManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()

        ThemeManager.shared.register(nil, for: .light)
        ThemeManager.shared.register(nil, for: .dark)
        ThemeManager.shared.currentInterfaceStyle = .light
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDefaultTheme() {
        XCTAssertEqual(ThemeManager.shared.currentInterfaceStyle, .light)
    }

    func testDarkTheme() {
        ThemeManager.shared.currentInterfaceStyle = .dark
        XCTAssertEqual(ThemeManager.shared.currentInterfaceStyle, .dark)
    }

    func testRegisterNewLightTheme() {
        let oldTheme = ThemeManager.shared.theme(for: .light)
        let newTheme = Theme(name: "testTheme", in: Bundle(for: ThemeManagerTests.self))
        ThemeManager.shared.register(newTheme, for: .light)
        let overridenTheme = ThemeManager.shared.theme(for: .light)

        XCTAssertNotEqual(overridenTheme, oldTheme)
        XCTAssertEqual(newTheme, overridenTheme)
    }

    func testRegisterNewDarkTheme() {
        let oldTheme = ThemeManager.shared.theme(for: .dark)
        let newTheme = Theme(name: "testTheme", in: Bundle(for: ThemeManagerTests.self))
        ThemeManager.shared.register(newTheme, for: .dark)
        let overridenTheme = ThemeManager.shared.theme(for: .dark)

        XCTAssertNotEqual(overridenTheme, oldTheme)
        XCTAssertEqual(newTheme, overridenTheme)
    }

    func testNewThemeNotOverridingOtherTheme() {
        let oldLightTheme = ThemeManager.shared.theme(for: .light)
        let oldDarkTheme = ThemeManager.shared.theme(for: .dark)
        let newLightTheme = Theme(name: "testTheme", in: Bundle(for: ThemeManagerTests.self))
        ThemeManager.shared.register(newLightTheme, for: .light)
        let overridenLightTheme = ThemeManager.shared.theme(for: .light)
        let overridenDarkTheme = ThemeManager.shared.theme(for: .dark)

        XCTAssertEqual(oldDarkTheme, overridenDarkTheme)
        XCTAssertNotEqual(oldLightTheme, overridenLightTheme)
    }

    func testRegisterNewCurrentTheme() {
        let oldLightTheme = ThemeManager.shared.theme(for: .current)
        let oldDarkTheme = ThemeManager.shared.theme(for: .current)
        let newLightTheme = Theme(name: "testTheme", in: Bundle(for: ThemeManagerTests.self))
        ThemeManager.shared.register(newLightTheme, for: .current)
        let overridenLightTheme = ThemeManager.shared.theme(for: .current)
        let overridenDarkTheme = ThemeManager.shared.theme(for: .current)

        XCTAssertEqual(oldDarkTheme, overridenDarkTheme)
        XCTAssertEqual(oldLightTheme, overridenLightTheme)
    }

    func testDefaultIsDark() {
        XCTAssertFalse(UserInterfaceStyle.light.isDark)
        XCTAssertTrue(UserInterfaceStyle.dark.isDark)
    }

    func testCurrentIsDark() {
        ThemeManager.shared.currentInterfaceStyle = .dark
        XCTAssertTrue(UserInterfaceStyle.current.isDark)
    }
}

