//
//  MPOLAssert.swift
//  MPOLKit
//
//  Created by Herli Halim on 13/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

public func MPLUnimplemented(_ function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) is not yet implemented", file: file, line: line)
}

public func MPLRequiresConcreteImplementation(_ function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) must be overriden in subclass implementations", file: file, line: line)
}

public func MPLCodingNotSupported(_ file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("NSCoding is not supported on this class", file: file, line: line)
}
