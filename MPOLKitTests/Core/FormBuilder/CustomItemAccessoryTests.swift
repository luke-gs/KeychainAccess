//
//  CustomItemAccessoryTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class CustomItemAccessoryTests: XCTestCase {

    func testThatItInstiates() {
        // Given
        let size = CGSize(width: 25, height: 25)
        let onCreate: () -> UIView = {
            return UIView()
        }

        // When
        let item = CustomItemAccessory(onCreate: onCreate, size: size)

        // Then
        XCTAssertNotNil(item.onCreate)
        XCTAssertEqual(item.size, size)
    }

    func testThatItCreatesTheView() {
        // Given
        let item = CustomItemAccessory(onCreate: {
            return UILabel()
        }, size: CGSize(width: 25, height: 25))

        // When
        let view = item.view()

        // Then
        XCTAssertTrue(view is UILabel)
    }

    func testThatItAppliesTheme() {
        // Given
        let item = CustomItemAccessory(onCreate: { return UILabel() }, size: CGSize(width: 25, height: 25))
            .onThemeChanged({ theme, view in
                view.tintColor = .red
            })


        // When
        let label = UILabel()
        item.apply(theme: ThemeManager.shared.theme(for: .current), toView: label)

        // Then
        XCTAssertEqual(label.tintColor, .red)
    }

}
