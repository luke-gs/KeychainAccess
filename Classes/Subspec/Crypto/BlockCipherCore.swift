//
//  BlockCipherCore.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CommonCrypto

/// Enum for Block Ciphers supported in PSCore
public enum BlockCipherCore: BlockCipherType {

    /// AES with 256 bit key (only cipher needed for now)
    case AES_256

    public var algorithm: CCAlgorithm {
        switch self {
        case .AES_256:
            return CCAlgorithm(kCCAlgorithmAES)
        }
    }

    public var keySize: Int {
        switch self {
        case .AES_256:
            return 32
        }
    }

    public var blockSize: Int {
        switch self {
        case .AES_256:
            // Block size is same for 128/256 bit keys
            return kCCBlockSizeAES128
        }
    }

    public var options: CCOptions {
        switch self {
        case .AES_256:
            return CCOptions(kCCOptionPKCS7Padding)
        }
    }
}

