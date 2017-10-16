//
//  CustomFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class CustomFormItemTests: XCTestCase {

    func testThatItHasADefaultWidth() {
        // Given
        let item = CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "Hello")
        let frame = CGRect(x: 0, y: 0, width: 200, height: 100)

        // When
        item.configure(CollectionViewFormSubtitleCell())
        let width = item.intrinsicWidth(in: UICollectionView(frame: frame, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertEqual(width, 200.0)
    }

    func testThatItHasADefaultHeight() {
        // Given
        let item = CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "Hello")
        let frame = CGRect(x: 0, y: 0, width: 200, height: 100)

        // When
        item.configure(CollectionViewFormSubtitleCell())
        let height = item.intrinsicHeight(in: UICollectionView(frame: frame, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 100.0, for: UITraitCollection())

        // Then
        XCTAssertEqual(height, 44.0)
    }

}
