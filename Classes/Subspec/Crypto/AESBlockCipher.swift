//
//  BlockCipherCore.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CommonCrypto

/// Enum for AES Block Ciphers
public enum AESBlockCipher: BlockCipherType {

    /// AES with 128 bit key
    case AES_128

    /// AES with 256 bit key
    case AES_256

    // MARK: - BlockCipherType

    public var algorithm: CCAlgorithm {
        return CCAlgorithm(kCCAlgorithmAES)
    }

    public var keySize: Int {
        switch self {
        case .AES_128:
            return 16
        case .AES_256:
            return 32
        }
    }

    public var blockSize: Int {
        // Block size is same for all key lengths
        return kCCBlockSizeAES128
    }

    public var options: CCOptions {
        // Use PCKS7 padding for all key lengths
        return CCOptions(kCCOptionPKCS7Padding)
    }
}

