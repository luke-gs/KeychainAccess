//
//  ImageSizingTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ImageSizingTests: XCTestCase {
    
    func testThatItInstantiates() {
        // Given
        let image = AssetManager.shared.image(forKey: .info)
        let size = CGSize(width: 200, height: 200)

        // When
        let sizing = ImageSizing(image: image, size: size)

        // Then
        XCTAssertEqual(sizing.image, image)
        XCTAssertEqual(sizing.size, size)
    }

    func testThatItIsSizable() {
        // Given
        let sizing = ImageSizing(image: AssetManager.shared.image(forKey: .info), size: CGSize(width: 20, height: 20))

        // When
        let theSizing = sizing.sizing()

        // Then
        XCTAssertEqual(sizing, theSizing)
    }

    func testThatItIsEqual() {
        // Given
        let sizingA = ImageSizing(image: AssetManager.shared.image(forKey: .info), size: CGSize(width: 20, height: 20))
        let sizingB = ImageSizing(image: AssetManager.shared.image(forKey: .info), size: CGSize(width: 20, height: 20))

        // When
        let same = sizingA == sizingB

        // Then
        XCTAssertTrue(same)
    }

    func testThatItIsNotEqualIfImagesAreDifferent() {
        // Given
        let sizingA = ImageSizing(image: AssetManager.shared.image(forKey: .info), size: CGSize(width: 20, height: 20))
        let sizingB = ImageSizing(image: AssetManager.shared.image(forKey: .add), size: CGSize(width: 20, height: 20))

        // When
        let same = sizingA == sizingB

        // Then
        XCTAssertFalse(same)
    }

    func testThatItIsNotEqualIfSizesAreDifferent() {
        // Given
        let sizingA = ImageSizing(image: AssetManager.shared.image(forKey: .info), size: CGSize(width: 10, height: 20))
        let sizingB = ImageSizing(image: AssetManager.shared.image(forKey: .info), size: CGSize(width: 20, height: 20))

        // When
        let same = sizingA == sizingB

        // Then
        XCTAssertFalse(same)
    }

    func testThatItHasSizingForImage() {
        // Given
        let image = AssetManager.shared.image(forKey: .info)

        // When
        let sizing = image?.sizing()

        // Then
        XCTAssertEqual(sizing?.image, image)
        XCTAssertEqual(sizing?.size, image?.size)
    }

    
}
