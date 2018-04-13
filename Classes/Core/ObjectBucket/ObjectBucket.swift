//
//  ObjectBucket.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//


/* TODO:
 *
 *  Find a better way of saving things
 */
open class ObjectBucket<T: NSSecureCoding> where T: AnyObject {

    private(set) public var objects: [T]?
    private(set) public var directory: URL
    private var directoryManager: DirectoryManager

    public required init(directory: URL) {
        self.directory = directory
        self.directoryManager = DirectoryManager(baseURL: directory)
    }

    public func object(for id: String) -> T {
        //TODO: Something actually useful
        return [] as! T
    }

    public func add(_ object: T) {
        objects = objects ?? []
        objects?.append(object)
    }

    public func remove(_ object: T) {
        objects = objects?.filter{$0 !== object}
    }
}

