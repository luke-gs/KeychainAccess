//
//  TestingDirective.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class TestingDirective {
    static var isTesting: Bool {
        return ProcessInfo.processInfo.environment["TEST"] == "1"
    }
}
