//
//  MediaAssetCache.swift
//  MPOLKit
//
//  Created by QHMW64 on 5/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import Cache

public class AssetCache {

    // The default asset cache
    // More can be created as this is not a singleton
    // This will not fail to instantiate with the default parameters
    public static let `default`: AssetCache = try! AssetCache()

    public let storage: Storage

    // Custom initialiser that can throw an error if they potentially intitialise the
    // configurations with invalid parameters
    public init(diskConfig: DiskConfig = DiskConfig(name: "assets"), memoryConfig: MemoryConfig? = nil) throws {
        storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
    }

    public func asset<T: Codable>(forKey key: String) -> T? {
        do {
            return try storage.entry(ofType: T.self, forKey: key).object
        } catch {
            print("Unable to find asset of type \(T.self) for key \(key)")
            return nil
        }
    }

    public func assetMetaData<T: Codable>(forKey key: String) -> Entry<T>? {
        do {
            return try storage.entry(ofType: T.self, forKey: key)
        } catch {
            print("Unable to find asset metadata of type \(T.self) for key \(key)")
            return nil
        }

    }

    @discardableResult
    public func store<T: Codable>(_ asset: T, for key: String) -> Bool {
        do {
            try storage.setObject(asset, forKey: key)
        } catch {
            print("Unable to store asset \(asset)")
            return false
        }
        return true

    }

    @discardableResult
    public func remove<T: Codable>(_ asset: T, withKey key: String) -> Bool {
        do {
            try storage.removeObject(forKey: key)
            return true
        } catch {
            print("Unable to remove asset \(asset)")
            return false
        }
    }

}

