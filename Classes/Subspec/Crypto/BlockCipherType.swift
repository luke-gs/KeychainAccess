//
//  BlockCipherType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CommonCrypto

/// Protocol for a block cipher
public protocol BlockCipherType {

    /// The cc encryption algorithm for this cipher
    var algorithm: CCAlgorithm { get }

    /// The key size in bytes for this cipher
    var keySize: Int { get }

    /// The block size in bytes for this cipher
    var blockSize: Int { get }

    /// The cc options for this cipher
    var options: CCOptions { get }
}

// Enum for block cipher operations
public enum BlockCipherOperation {
    case encrypt
    case decrypt

    /// Method needed because Swift does not allow setting these as enum case value
    var operation: CCOperation {
        switch self {
        case .encrypt: return CCOperation(kCCEncrypt)
        case .decrypt: return CCOperation(kCCDecrypt)
        }
    }
}
