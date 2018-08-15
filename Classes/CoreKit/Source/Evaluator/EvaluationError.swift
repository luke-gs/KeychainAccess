//
//  EvaluationError.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public enum EvaluationError: Error {
    case invalidKey
    case nonExistentState
}

extension EvaluationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "The key provided is invalid."
        case .nonExistentState:
            return "The state you are trying to retrieve or the key is invalid."
        }
    }
}
