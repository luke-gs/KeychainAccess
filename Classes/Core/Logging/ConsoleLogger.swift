//
//  ConsoleLogger.swift
//  MPOLKit
//
//  Created by QHMW64 on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct ConsoleLogger: Loggable {
    public func log(output log: String) {
        print(log)
    }
}
