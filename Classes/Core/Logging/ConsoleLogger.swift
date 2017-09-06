//
//  ConsoleLogger.swift
//  MPOLKit
//
//  Created by QHMW64 on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A basic console logger wthat will wirte a provided text to the console
public struct ConsoleLogger: Loggable {

    // Blank init
    public init() {

    }

    public func log(output log: String) {
        print(log)
    }
}
