//
//  DirectoryManager.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import KeychainSwift

public class DirectoryManager: DirectoryManaging {

    private var baseURL: URL
    private let keychain = KeychainSwift()
    private let operationQueue: OperationQueue

    required public init(baseURL: URL) {
        self.baseURL = baseURL
        self.operationQueue = OperationQueue()
        self.operationQueue.name = "DirectoryManagerOperationQueue"
    }

    //MARK: Directory

    @discardableResult public func write(_ object: Any, to path: String) -> Bool {
        let url = baseURL.appendingPathComponent(path)
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        return try! FileManager.default.createFile(atPath: url.path, contents: data, withIntermediateDirectories: true)
    }

    public func read(from path: String) -> Any? {
        let url = baseURL.appendingPathComponent(path)
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: url.path)
        return data
    }
    
    public func remove(at path: String) throws {
        let url = baseURL.appendingPathComponent(path)
        try FileManager.default.removeItem(at: url)
    }

    //MARK: Keychain

    @discardableResult public func write(_ object: Any?, toKeyChain key: String) -> Bool {
        guard let object = object else {
            return keychain.delete(key)
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        return keychain.set(data, forKey: key)
    }

    public func read(fromKeyChain key: String) -> Any? {
        guard let data = keychain.getData(key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }
}

/// Protocol for the directory manager. (Mainly for clean docs)
public protocol DirectoryManaging {

    /// Initialise the directory manager with a base url
    ///
    ///All subsequent write/reads will be appending to the base url
    /// - Parameter baseURL: the base url to use
    init(baseURL: URL)

    /// Write the object to a directory at sub path of the base url
    ///
    /// If the intermediate directories don't exist, it will create them for you
    /// - Parameters:
    ///   - object: the object to archive
    ///   - path: the sub path to archive to
    /// - Returns: true of the write was successful
    @discardableResult func write(_ object: Any, to path: String) -> Bool

    /// Read from the directory and unarchive an object
    ///
    /// - Parameter path: the path of the object
    /// - Returns: the object unarchived from the path. nil if no object was found.
    func read(from path: String) -> Any?

    /// Removes the file at the given path
    ///
    /// - Parameter path: the path of the file
    /// - Returns: returns true if removal was successful
    /// - Throws: throws error if there was a problem removing the file
    func remove(at path: String) throws

    /// Write an object to the keychain
    ///
    /// - Parameters:
    ///   - object: the object to write to keychain
    ///   - key: the key to store it under
    /// - Returns: true of the write was successful
    @discardableResult func write(_ object: Any?, toKeyChain key: String) -> Bool

    /// Read from the keychain
    ///
    /// - Parameter key: the key of the object in keychain
    /// - Returns: the unarchived object
    func read(fromKeyChain key: String) -> Any?
}

public extension FileManager {

    /// Creates a file with the specified content and attributes at the given location.
    /// If you specify nil for the attributes parameter, this method uses a default set of values for the owner, group, and permissions of any newly created directories in the path. Similarly, if you omit a specific attribute, the default value is used. The default values for newly created files are as follows:
    /// - Permissions are set according to the umask of the current process. For more information, see umask.
    /// - The owner ID is set to the effective user ID of the process.
    /// - The group ID is set to that of the parent directory.
    /// If a file already exists at path, this method overwrites the contents of that file if the current process has the appropriate privileges to do so.
    ///
    /// - Parameters:
    ///   - path: The path for the new file.
    ///   - data: A data object containing the contents of the new file.
    ///   - createIntermediates: If true, this method creates any non-existent parent directories as part of creating the directory in path. If false, this method fails if any of the intermediate parent directories does not exist. This method also fails if any of the intermediate path elements corresponds to a file and not a directory.
    ///   - attr: A dictionary containing the attributes to associate with the new file. You can use these attributes to set the owner and group numbers, file permissions, and modification date. For a list of keys, see File Attribute Keys. If you specify nil for attributes, the file is created with a set of default attributes.
    /// - Returns: true if the operation was successful or if the item already exists, otherwise false.
    /// - Throws: throws if error has occurred
    func createFile(atPath path: String,
                    contents data: Data?,
                    withIntermediateDirectories createIntermediates: Bool,
                    attributes attr: [String : Any]? = nil) throws -> Bool
    {
        guard let url = URL(string: path) else { return false }
        try FileManager.default.createDirectory(atPath: url.deletingLastPathComponent().path,
                                                withIntermediateDirectories: createIntermediates,
                                                attributes: attr)
        return createFile(atPath: path, contents: data, attributes: attr)
    }
}
