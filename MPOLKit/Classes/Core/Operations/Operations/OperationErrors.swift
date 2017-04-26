//
//  OperationErrors.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

let OperationErrorDomain = "OperationErrors"

public enum OperationErrorCode: Int {
    case conditionFailed = 1
    case executionFailed = 2
}

extension NSError {
    convenience init(code: OperationErrorCode, userInfo: [AnyHashable: Any]? = nil) {
        self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}

// This makes it easy to compare an `NSError.code` to an `OperationErrorCode`.
public func ==(lhs: Int, rhs: OperationErrorCode) -> Bool {
    return lhs == rhs.rawValue
}

public func ==(lhs: OperationErrorCode, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}
