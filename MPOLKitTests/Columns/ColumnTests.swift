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
    
    // MARK: - No margins
    
    /// Tests all columns with no margin
    func testNoMargin_fit() {
        let width: CGFloat = 960
        
        /// All these columns should fit
        let columns = [
            ColumnInfo(minimumWidth: 200, maximumWidth: 280),
            ColumnInfo(minimumWidth: 300, maximumWidth: 1000),
            ColumnInfo(minimumWidth: 192, maximumWidth: 192),
        ]
        
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width)
        
        // Check widths match expectation
        XCTAssert(calculated[0].actualWidth == 280)
        XCTAssert(calculated[1].actualWidth == 488)
        XCTAssert(calculated[2].actualWidth == 192)
    }
    
    /// Tests one column with no margin fits
    func testNoMargin_fit_1() {
        let width: CGFloat = 240
        
        /// Only 1 column should fit
        let columns = [
            ColumnInfo(minimumWidth: 200, maximumWidth: 280),
            ColumnInfo(minimumWidth: 300, maximumWidth: 1000),
            ColumnInfo(minimumWidth: 192, maximumWidth: 192),
        ]
        
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width)
        
        // Check widths match expectation
        XCTAssert(calculated[0].actualWidth == 240)
        XCTAssert(calculated[1].actualWidth == 0)
        XCTAssert(calculated[2].actualWidth == 0)
    }
    
    // MARK: - With margins
    
    /// Tests all columns fit with a margin
    func testWithMargin_fit() {
        let width: CGFloat = 960
        let margin: CGFloat = 24
        
        /// All these columns should fit
        let columns = [
            ColumnInfo(minimumWidth: 200, maximumWidth: 280),
            ColumnInfo(minimumWidth: 300, maximumWidth: 1000),
            ColumnInfo(minimumWidth: 192, maximumWidth: 192),
        ]
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width, margin: margin)
        
        // Check widths match expectation
        XCTAssert(calculated[0].actualWidth == 280)
        XCTAssert(calculated[1].actualWidth == 440)
        XCTAssert(calculated[2].actualWidth == 192)
        
        // Check margins match expectation
        XCTAssert(calculated[0].leadingMargin == 0)
        XCTAssert(calculated[0].trailingMargin == 24)
        XCTAssert(calculated[1].leadingMargin == 24)
        XCTAssert(calculated[1].trailingMargin == 24)
        XCTAssert(calculated[2].leadingMargin == 24)
        XCTAssert(calculated[2].trailingMargin == 0)
    }
    
    /// Tests all columns fit with a margin
    func testWithMargin_fit_1() {
        let width: CGFloat = 240
        let margin: CGFloat = 24
        
        /// Only one column should fit
        let columns = [
            ColumnInfo(minimumWidth: 200, maximumWidth: 280),
            ColumnInfo(minimumWidth: 300, maximumWidth: 1000),
            ColumnInfo(minimumWidth: 192, maximumWidth: 192),
        ]
        
        let calculated = ColumnInfo.calculateWidths(for: columns, in: width, margin: margin)
        
        // Check widths match expectation
        XCTAssert(calculated[0].actualWidth == 240)
        XCTAssert(calculated[1].actualWidth == 0)
        XCTAssert(calculated[2].actualWidth == 0)
        
        // Check margins match expectation
        XCTAssert(calculated[0].leadingMargin == 0)
        XCTAssert(calculated[0].trailingMargin == 0)
        XCTAssert(calculated[1].leadingMargin == 0)
        XCTAssert(calculated[1].trailingMargin == 0)
        XCTAssert(calculated[2].leadingMargin == 0)
        XCTAssert(calculated[2].trailingMargin == 0)
    }
    
}
