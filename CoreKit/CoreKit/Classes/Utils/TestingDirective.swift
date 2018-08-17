//
//  TestingDirective.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class TestingDirective {
    static var isTesting: Bool {
        return ProcessInfo.processInfo.environment["TEST"] == "1"
    }
}
