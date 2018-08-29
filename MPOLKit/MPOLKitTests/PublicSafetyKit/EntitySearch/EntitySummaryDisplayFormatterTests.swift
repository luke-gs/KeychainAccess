//
//  EntitySummaryDisplayFormatterTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 7/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class EntitySummaryDisplayFormatterTests: XCTestCase {

    
    func testThatItRegistersANewType() {
        // Given
        let formatter = EntitySummaryDisplayFormatter()

        // When
        formatter.registerEntityType(SpecialPerson.self,
                                     forSummary: .function({ entity in
                                        return SpecialPersonDisplayable(entity)
                                     }),
                                     andPresentable: .function({ _ in
                                        return SpecialPersonDetail.detail
                                     }))

        // Then
        let person = SpecialPerson()

        let summary = formatter.summaryDisplayForEntity(person)
        let presentable = formatter.presentableForEntity(person)

        XCTAssert(summary is SpecialPersonDisplayable)
        XCTAssert((presentable as? SpecialPersonDetail) == SpecialPersonDetail.detail)
    }

    func testThatItRemovesRegistration() {
        // Given
        let formatter = EntitySummaryDisplayFormatter()
        formatter.registerEntityType(SpecialPerson.self,
                                     forSummary: .function({ entity in
                                        return SpecialPersonDisplayable(entity)
                                     }),
                                     andPresentable: .function({ _ in
                                        return SpecialPersonDetail.detail
                                     }))

        // When
        formatter.removeRegistrationForEntityType(SpecialPerson.self)

        // Then
        let person = SpecialPerson()
        let summary = formatter.summaryDisplayForEntity(person)
        let presentable = formatter.presentableForEntity(person)

        XCTAssertNil(summary)
        XCTAssertNil(presentable)
    }

}

class SpecialPerson: MPOLKitEntity {

}

class SpecialPersonDisplayable: EntitySummaryDisplayable {

    required init(_ entity: MPOLKitEntity) {

    }

    func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        return nil
    }

    var category: String?

    var title: String?

    var detail1: String?

    var detail2: String?

    var borderColor: UIColor?

    var iconColor: UIColor?

    var badge: UInt = 0

}

enum SpecialPersonDetail: Presentable {
    case detail
}
