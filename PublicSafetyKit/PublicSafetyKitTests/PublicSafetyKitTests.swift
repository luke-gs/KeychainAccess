//
//  PublicSafetyKitTests.swift
//  PublicSafetyKitTests
//
//  Created by Trent Fitzgibbon on 17/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

@_exported import CoreKit
@_exported import PatternKit
@testable @_exported import PublicSafetyKit

/// Principal class created before any tests are run
class TestSetup: NSObject {
    override init() {
        MPOLKitInitialize()
    }
}
