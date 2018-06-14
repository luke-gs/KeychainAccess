//
//  NotificationService.swift
//  APNS Extension
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UserNotifications
import MPOLKitCrypto
import KeychainAccess

class NotificationService: UNNotificationServiceExtension {

    private let PushKeyKeychainKey = "NotificationManager.pushKey"
    private let keychain: Keychain = SharedKeychainCapability.defaultKeychain

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    open func decryptContentAsData(_ content: String) -> Data? {
        guard let data = Data(base64Encoded: content) else { return nil }
        guard let pushKeyData = try? keychain.getData(PushKeyKeychainKey), let pushKey = pushKeyData else { return nil }
        return CryptoUtils.decryptCipher(AESBlockCipher.AES_256, dataWithIV: data, keyData: pushKey)
    }

    open func updateContent(mutableContent: UNMutableNotificationContent, userInfo: [AnyHashable : Any]) {
        // Decrypt the content
        if let encryptedContent = userInfo["content"] as? String {
            if let data = decryptContentAsData(encryptedContent) {
                // Parse content into model object
                if let content = try? JSONDecoder().decode(SearchNotificationContent.self, from: data) {
                    switch content.type {
                    // TODO: handle Search app loud notification types
                    // case "hothit":
                    //    mutableContent.title = "Hot Hit"
                    //    mutableContent.body = "something blah"
                    default:
                        break
                    }
                } else {
                    // If not matching expected object, just show decrypted content as message
                    mutableContent.body = String(data: data, encoding: .utf8) ?? ""
                }
            }
        }
    }

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // Update the content
            updateContent(mutableContent: bestAttemptContent, userInfo: request.content.userInfo)
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
