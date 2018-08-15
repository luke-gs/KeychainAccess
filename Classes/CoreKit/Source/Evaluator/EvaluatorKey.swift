//
//  EvaluatorKey.swift
//  MPOLKit
//
//  Created by QHMW64 on 1/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct EvaluatorKey: RawRepresentable, Equatable, Hashable {

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public static func ==(lhs: EvaluatorKey, rhs: EvaluatorKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public var hashValue: Int {
        return rawValue.hashValue
    }
}
