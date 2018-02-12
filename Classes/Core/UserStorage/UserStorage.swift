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
    case KeyExists
}

// MARK: -

public class UserStorage {

    // MARK: Public

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

    func add(object: Any, key: String, flag: UserStorageFlag) throws {
        let safeKey = key.slashEscaped()

        if let existingPath = pathForKey(key: safeKey),
            existingPath.flag != flag {
            throw UserStorageError.KeyExists
        }

        // The Path = "BaseURL / UserID / Flag / Key.awesomefile"
        let path = "\(flag.rawValue)/\(safeKey)"
        let result = directoryManager.write(object, to: path)
        print(result)
    }


    // MARK: Retrieve

    func retrieve(key: String) -> Any? {
        let safeKey = key.slashEscaped()
        guard let storagePath = pathForKey(key: safeKey) else { return nil }
        return directoryManager.read(from: storagePath.path)
    }


    // MARK: Delete

    func remove(key: String) throws {
        let safeKey = key.slashEscaped()
        guard let storagePath = pathForKey(key: safeKey) else { return }
        try directoryManager.remove(at: storagePath.path)
    }

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
