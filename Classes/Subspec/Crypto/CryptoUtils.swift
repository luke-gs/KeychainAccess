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
//
// We use this rather than a 3rd party pod for increased security and the added benefit
// of hardware accelerated AES encryption
import CommonCrypto

public class CryptoUtils {

    /// Generate a key of the given type
    static public func generateKey(for cipher: BlockCipherType) -> Data? {
        return generateRandomBytes(count: cipher.keySize)
    }

    /// Generate secure random bytes of data
    static public func generateRandomBytes(count: Int) -> Data? {
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

    /// Perform a block based cipher operation on data
    public static func performCipher(_ cipher: BlockCipherType, operation: BlockCipherOperation, data: Data, keyData: Data, ivData: Data? = nil) -> Data? {

        // Make sure we have enough key data
        assert(keyData.count >= cipher.keySize)

        // For block ciphers, the output size will always be less than or equal to the input size plus
        // the size of one block due to padding
        let bufferLength = data.count + cipher.blockSize
        var buffer = Data(count: bufferLength)

        // Use provided initialization vector or 0x00 filled array
        let ivData = ivData ?? Data(repeating: 0, count: cipher.blockSize)

        var numBytesEncrypted: Int = 0

        let result = buffer.withUnsafeMutableBytes { bufferBytes in
            data.withUnsafeBytes { dataBytes in
                ivData.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(operation.operation,
                                cipher.algorithm,
                                cipher.options,
                                keyBytes,
                                cipher.keySize,
                                ivBytes,
                                dataBytes,
                                data.count,
                                bufferBytes,
                                bufferLength,
                                &numBytesEncrypted)
                    }
                }
            }
        }

        if result == errSecSuccess {
            // Return the buffer minus any extra space not used
            buffer.removeSubrange(numBytesEncrypted..<buffer.count)
            return buffer;
        } else {
            return nil
        }
    }
}

