//
//  MPOLAssert.swift
//  MPOLKit
//
//  Created by Herli Halim on 13/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

public func MPOLUnimplemented(_ function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) is not yet implemented", file: file, line: line)
}

public func MPOLRequiresConcreteImplementation(_ function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) must be overriden in subclass implementations", file: file, line: line)
}
