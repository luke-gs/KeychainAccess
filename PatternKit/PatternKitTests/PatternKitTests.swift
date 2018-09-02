//
//  PatternKitTests.swift
//  PatternKitTests
//
//  Created by Trent Fitzgibbon on 17/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

@_exported import CoreKit
@testable @_exported import PatternKit

/// Principal class created before any tests are run
class TestSetup: NSObject {
    override init() {
        MPOLKitInitialize()
    }
}
