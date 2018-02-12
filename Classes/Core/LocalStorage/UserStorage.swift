//
//  UserStorage.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 1/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

enum UserStorageFlag: String {
    case session = "session"
    case retain = "retain"

    static let allValues = [session, retain]
}

class UserStorage {

    // MARK: Public

    public static func purgeAllUsers() {
        try? FileManager.default.removeItem(at: UserStorage.baseURL)
    }

    // MARK: Private

    private static let baseURL = AppGroup.appBaseFilePath().appendingPathComponent("UserStorage")

    private var directoryManager: DirectoryManager


    // MARK:

    init(userID: String) {
        let baseURL = UserStorage.baseURL.appendingPathComponent(userID)
        self.directoryManager = DirectoryManager(baseURL: baseURL)
    }


    // MARK: Add

    public func add(object: Any, key: String, flag: UserStorageFlag) {
        // Check key doesn't exist

        // The Path = "BaseURL / UserID / Flag / Key.awesomefile"
        let path = "\(flag.rawValue)/\(key)"
        print(path)
        let result = directoryManager.write(object, to: path)
        print(result)
    }


    // MARK: Retrieve

    public func retrieve(key: String) -> Any? {
        guard let path = pathForKey(key: key) else { return nil }
        return directoryManager.read(from: path)
    }


    // MARK: Delete

    public func remove(key: String) throws {
        guard let path = pathForKey(key: key) else { return }
        try directoryManager.remove(at: path)
    }

    public func purge(flag: UserStorageFlag) throws {
        try directoryManager.remove(at: flag.rawValue)
    }

    // MARK: Helper

    private func pathForKey(key: String) -> String? {
        for flag in UserStorageFlag.allValues {
            guard let filenames = directoryManager.contents(of: flag.rawValue) else { continue }
            guard let path = filenames.first(where: { $0 == key; }) else { continue }

            return "\(flag)/\(path)"
        }

        return nil
    }
}
