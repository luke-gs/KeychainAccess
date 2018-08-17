//
//  ImageLoadableTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ImageLoadableTests: XCTestCase {

    let image = AssetManager.shared.image(forKey: .info)

    func testThatItImageImplementsImageLoadable() {
        // When
        image?.loadImage(completion: { (finalImage) in
            // Then
            XCTAssertEqual(finalImage.sizing().image, self.image)
        })

        XCTAssertNotNil(image)
    }

    func testThatItReturnsImageSizable() {
        // When
        let sizing = image?.sizing()

        // Then
        XCTAssertEqual(sizing?.image, image)
        XCTAssertEqual(sizing?.size, image?.size)
    }

}
