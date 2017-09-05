//
//  Logger.swift
//  MPOLKit
//
//  Created by QHMW64 on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol Loggable {
    func log(output log: String)
}

public class Logger {
    private var loggers: [Loggable] = []
    func log(text: String) {
        loggers.forEach({ $0.log(output: text) })
    }

    public init(loggers: [Loggable]) {
        self.loggers = loggers
    }
}
