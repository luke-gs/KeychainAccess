//
//  CipherOperation.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CommonCrypto

public enum CipherOperation {
    case encrypt
    case decrypt

    /// Method needed because Swift does not allow setting these as enum case value
    var value: CCOperation {
        switch self {
        case .encrypt: return CCOperation(kCCEncrypt)
        case .decrypt: return CCOperation(kCCDecrypt)
        }
    }
}
