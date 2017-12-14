//
//  ColumnTests.swift
//  MPOLKitTests
//
//  Created by Kyle May on 13/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ColumnTests: XCTestCase {
    
    func testTruncatesColumns() {
        var columns: [ColumnInfo] = []
        
        let width: CGFloat = 800
        
        /// Not all columns should fit
        columns = [
            ColumnInfo(minimumWidth: 200, maximumWidth: 200),
            ColumnInfo(minimumWidth: 400, maximumWidth: 1000),
            ColumnInfo(minimumWidth: 500, maximumWidth: 1000),
        ]
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width)
        
        // Assert widths are expected
        XCTAssertEqual(calculated[0], 200)
        XCTAssertEqual(calculated[1], 600)
    }

    func testWidths_FirstAuto() {
        var columns: [ColumnInfo] = []
        
        let width: CGFloat = 850
        
        /// All these columns should fit in the widths
        columns = [
            ColumnInfo(minimumWidth: 400, maximumWidth: 1000),
            ColumnInfo(minimumWidth: 200, maximumWidth: 200),
            ColumnInfo(minimumWidth: 200, maximumWidth: 200),
        ]
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width)
        
        // Assert all columns made it in
        XCTAssert(columns.count == calculated.count)

        // Assert widths are expected
        XCTAssertEqual(calculated[0], 450)
        XCTAssertEqual(calculated[1], 200)
        XCTAssertEqual(calculated[2], 200)
    }
    
    func testWidths_MiddleAuto() {
        var columns: [ColumnInfo] = []
        
        let width: CGFloat = 850
        
        /// All these columns should fit in the widths
        columns = [
            ColumnInfo(minimumWidth: 200, maximumWidth: 200),
            ColumnInfo(minimumWidth: 400, maximumWidth: 1000),
            ColumnInfo(minimumWidth: 200, maximumWidth: 200),
        ]
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width)
        
        // Assert all columns made it in
        XCTAssert(columns.count == calculated.count)
        
        // Assert widths are expected
        XCTAssertEqual(calculated[0], 200)
        XCTAssertEqual(calculated[1], 450)
        XCTAssertEqual(calculated[2], 200)
    }
    
    func testWidths_EndAuto() {
        var columns: [ColumnInfo] = []
        
        let width: CGFloat = 850
        
        /// All these columns should fit in the widths
        columns = [
            ColumnInfo(minimumWidth: 200, maximumWidth: 200),
            ColumnInfo(minimumWidth: 200, maximumWidth: 200),
            ColumnInfo(minimumWidth: 400, maximumWidth: 1000),
        ]
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width)
        
        // Assert all columns made it in
        XCTAssert(columns.count == calculated.count)
        
        // Assert widths are expected
        XCTAssertEqual(calculated[0], 200)
        XCTAssertEqual(calculated[1], 200)
        XCTAssertEqual(calculated[2], 450)
    }
}
