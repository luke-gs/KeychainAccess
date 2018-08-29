//
//  EntitySummarySearchResultViewModelTests.swift
//  MPOLKitTests
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest


class EntitySummarySearchResultViewModelTests: XCTestCase {
    
    func testFailsWhenStyleInNotAllowed() {
        let model = EntitySummarySearchResultViewModel.dummyModel()
        model.setStyleIfAllowed(.list)
        model.allowedStyles = [.list]
        XCTAssertEqual(EntityDisplayStyle.list, model.style)
        let result = model.setStyleIfAllowed(.grid)
        XCTAssertFalse(result)
        XCTAssert(model.style == .list)
    }
    
    func testUpdatesStyleWhenAllowedStylesChange() {
        let model = EntitySummarySearchResultViewModel.dummyModel()
        model.allowedStyles = EntityDisplayStyle.all
        XCTAssert(model.setStyleIfAllowed(.grid))
        model.allowedStyles = [.list]
        XCTAssertEqual(EntityDisplayStyle.list, model.style)
    }
}

extension EntitySummarySearchResultViewModel {
    static func dummyModel() -> EntitySummarySearchResultViewModel<MPOLKitEntity> {
        let searchAggregate = AggregatedSearch<MPOLKitEntity>(requests: [])
        return EntitySummarySearchResultViewModel<MPOLKitEntity>(title: "", aggregatedSearch: searchAggregate)
    }
}
