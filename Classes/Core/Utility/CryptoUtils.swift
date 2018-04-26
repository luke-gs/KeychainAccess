//
//  CryptoUtils.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

// Note: CommonCrypto is normally imported into a Swift app using a bridging header.
// But you cannot use bridging headers in frameworks, and you cannot import the
// CommonCrypto framework into the umbrella header. So instead, we have defined our
// own module.modulemap file under mPolKit-iOS/CommonCrypto that imports the
// <CommonCrypto/CommonCrypto.h> header
import CommonCrypto

public class CryptoUtils {

    /// Enum for different key types
    public enum KeyType: Int {
        case AES_128 = 16
        case AES_256 = 32

        var keySize: Int {
            return rawValue
        }
    }

    /// Generate a key of the given type
    static func generateKey(of type: KeyType = .AES_256) -> Data? {
        return generateRandomBytes(count: type.keySize)
    }

    /// Generate secure random bytes of data
    static func generateRandomBytes(count: Int) -> Data? {
        var keyData = Data(count: count)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            return nil
        }
    }
}
