//
//  TestSetup.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PatternKit

/// Principal class created before any tests are run
class TestSetup: NSObject {
    override init() {
        MPOLKitInitialize()
    }
}
