//
//  UserStorage.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 1/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

// MARK: UserStorageFlag

public enum UserStorageFlag {
    case session
    case retain
    case custom(String)
}

extension UserStorageFlag: RawRepresentable {
    public typealias RawValue = String
    private static let sessionString = "session"
    private static let retainString = "retain"

    public init(rawValue: RawValue) {
        switch rawValue {
        case UserStorageFlag.sessionString: self = .session
        case UserStorageFlag.retainString: self = .retain
        default: self = .custom(rawValue)
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .session: return UserStorageFlag.sessionString
        case .retain: return UserStorageFlag.retainString
        case .custom(let string): return string
        }
    }
}

// MARK: -

private struct UserStoragePath {
    let flag: UserStorageFlag
    let path: String
}

public enum UserStorageError: Error {
    case keyExists
}

// MARK: -

public class UserStorage {

    // MARK: Public

    /// Completely nukes all User Storage for all users.
    static func purgeAllUsers() {
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

    /// Add an object to user storage.
    ///
    /// - Parameters:
    ///   - object: the object to store
    ///   - key: the key to store it under. Must be unique for this user.
    ///   - flag: Flag to categorise the object under
    func add(object: Any, key: String, flag: UserStorageFlag) throws {
        let safeKey = key.slashEscaped()

        if let existingPath = pathForKey(key: safeKey),
            existingPath.flag != flag {
            throw UserStorageError.keyExists
        }

        // The Path = "BaseURL / UserID / Flag / Key.awesomefile"
        let path = "\(flag.rawValue)/\(safeKey)"
        let result = directoryManager.write(object, to: path)
        print(result)
    }


    // MARK: Retrieve

    /// Retrieve an object from user storage.
    ///
    /// - Parameters:
    ///   - key: The unique key to retrieve the object with
    /// - Returns: Object if found, otherwise nil
    func retrieve(key: String) -> Any? {
        let safeKey = key.slashEscaped()
        guard let storagePath = pathForKey(key: safeKey) else { return nil }
        return directoryManager.read(from: storagePath.path)
    }


    // MARK: Delete

    /// Remove an object from user storage.
    /// If no object is found, this method has no effect.
    ///
    /// - Parameters:
    ///   - key: The unique key to identify the object with
    /// - Throws: On error only.
    func remove(key: String) throws {
        let safeKey = key.slashEscaped()
        guard let storagePath = pathForKey(key: safeKey) else { return }
        try directoryManager.remove(at: storagePath.path)
    }

    /// Removes all objects with the matched flag from storage.
    ///
    /// - Parameters:
    ///   - flag: The flag to identify which objects will be removed.
    func purge(flag: UserStorageFlag) throws {
        try directoryManager.remove(at: flag.rawValue)
    }

    // MARK: Helper

    private func pathForKey(key: String) -> UserStoragePath? {
        guard let allFlags = directoryManager.contents() else { return nil }

        for flag in allFlags {
            guard let filenames = directoryManager.contents(of: flag) else { continue }
            guard let path = filenames.first(where: { $0 == key; }) else { continue }

            return UserStoragePath(flag: UserStorageFlag(rawValue: flag), path: "\(flag)/\(path)")
        }

        return nil
    }
}

private extension String {
    func slashEscaped() -> String {
        return self.replacingOccurrences(of: "/", with: "_")
    }
}
