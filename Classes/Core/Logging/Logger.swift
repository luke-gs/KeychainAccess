//
//  Logger.swift
//  MPOLKit
//
//  Created by QHMW64 on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A protocol that defines the ability to log a provided string
public protocol Loggable {
    func log(output log: String)
}

/// ---------------------------------------------------------------------------------------
/// The Logger that manages multiple instances of Loggables
/// ---------------------------------------------------------------------------------------
public class Logger {

    /// Private property containing the loggers that will be delegated to log the parsed test
    private var loggers: [Loggable] = []

    /// ---------------------------------------------------------------------------------------
    /// Overarching log method
    ///
    /// - Parameter text: The text to be logged
    /// ---------------------------------------------------------------------------------------
    func log(text: String) {

        // Each logger will handle the text it has been provided in its own manner
        loggers.forEach({ $0.log(output: text) })
    }

    /// ---------------------------------------------------------------------------------------
    /// Public initialiser
    ///
    /// - Parameter loggers: The loggable objects that will be resposnible for logging the text
    /// ---------------------------------------------------------------------------------------
    public init(loggers: [Loggable]) {
        self.loggers = loggers
    }
}
