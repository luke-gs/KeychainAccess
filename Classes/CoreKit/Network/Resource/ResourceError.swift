//
//  ResourceError.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public enum ResourceError: Error {
    case invalidResourceData
}

extension ResourceError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .invalidResourceData:
            return "The response data is invalid or non-existent."
        }
    }
}
