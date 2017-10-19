//
//  BaseSupplementaryFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class BaseSupplementaryFormItemTests: XCTestCase {

    func testThatItInstantiatesCorrectly() {
        // Given
        let type = CollectionViewFormHeaderView.self
        let kind = UICollectionElementKindSectionHeader
        let reuseIdentifier = "ABC"

        // When
        let item = BaseSupplementaryFormItem(viewType: type, kind: kind, reuseIdentifier: reuseIdentifier)

        // Then
        XCTAssertTrue(item.viewType == type)
        XCTAssertEqual(item.kind, kind)
        XCTAssertEqual(item.reuseIdentifier, reuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = BaseSupplementaryFormItem(viewType: CollectionViewFormHeaderView.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: "reuseIdentifier")

        // When
        item.elementIdentifier("Hello")
            .reuseIdentifier("HelloReuse")
            .onConfigured(nil)
            .onThemeChanged(nil)

        // Then
        XCTAssertEqual(item.elementIdentifier, "Hello")
        XCTAssertEqual(item.reuseIdentifier, "HelloReuse")
        XCTAssertNil(item.onConfigured)
        XCTAssertNil(item.onThemeChanged)
    }

    func testThatItAcceptsVisitor() {
        // Given
        let item = BaseSupplementaryFormItem(viewType: CollectionViewFormHeaderView.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: "reuseIdentifier")
        let visitor = SubmissionValidationVisitor()

        // When
        item.accept(visitor)

        // Then
        XCTAssertTrue(visitor.result == .valid)
    }

    func testThatItDecoratesCellsWithSpecifiedColors() {
        // Given
        let view = CollectionViewFormHeaderView()
        let item = BaseSupplementaryFormItem(viewType: CollectionViewFormHeaderView.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: "reuseIdentifier")
        item.onThemeChanged { (view, theme) in
            guard let view = view as? CollectionViewFormHeaderView else { return }
            view.separatorColor = .blue
            view.tintColor = .orange
        }

        // When
        item.decorate(view, withTheme: ThemeManager.shared.theme(for: .current))

        // Then
        XCTAssertEqual(view.separatorColor, .blue)
        XCTAssertEqual(view.tintColor, .orange)
    }

}
