//
//  UserSession.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public enum SessionError: Error {
    case alreadyBegun(String)
}

public class UserSession: NSObject {
    public static let current = UserSession()

    private(set) var basePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private(set) var token: OAuthAccessToken? {
        set {
            self.document.token = newValue
            saveSession()
        }
        get {
            return self.document.token
        }
    }

    private(set) public var user: User? {
        set {
            self.document.user = newValue
            saveSession()
        }
        get {
            return self.document.user
        }
    }

    public var recentlyViewed: [MPOLKitEntity]? {
        set {
            self.document.recentlyViewed = newValue
            saveSession()
        }
        get {
            return self.document.recentlyViewed
        }
    }

    public var recentlySearched: [Searchable]? {
        set {
            self.document.recentlySearched = newValue
            saveSession()
        }
        get {
            return self.document.recentlySearched
        }
    }

    private lazy var document: UserSessionDocument = {
        return UserSessionDocument(fileURL: self.basePath)
    }()

    public static func startSession(user: User,
                                    token: OAuthAccessToken,
                                    basePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!) throws
    {
        guard UserSession.current.user == nil
            else { throw SessionError.alreadyBegun("Session in progress for user: \(UserSession.current.user!.username)") }

        UserSession.current.createSession()

        UserSession.current.user = user
        UserSession.current.token = token
    }

    public func endSession() {
        user = nil
        token = nil
        recentlySearched = nil
        recentlyViewed = nil
    }

    public func renewSession(with token: OAuthAccessToken) {
        self.token = token
    }

    //MARK: SAVING

    private func createSession() {
        document.save(to: document.fileURL, for: .forCreating) { success in
            print("Create \(success)")
        }
    }

    private func saveSession() {
        document.save(to: document.fileURL, for: .forOverwriting) { success in
            print("Save \(success)")
        }
    }

    //MARK: RESTORING

    private func restoreSession() {
        document.open { success in
            print(success)
        }
    }
}


fileprivate class UserSessionDocument: UIDocument {

    lazy var fileWrapper: FileWrapper = {
        let wrapper  = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.filename = UUID().uuidString
        return wrapper
    }()
    
    var token: OAuthAccessToken? {
        didSet {
            replaceWrapper(key: "token", object: token)
        }
    }

    var user: User? {
        didSet {
            replaceWrapper(key: "user", object: user)
        }
    }

    var recentlyViewed: [MPOLKitEntity]? = [] {
        didSet {
            replaceWrapper(key: "recentlyViewed", object: recentlyViewed)
        }
    }

    var recentlySearched: [Searchable]? = [] {
        didSet {
            replaceWrapper(key: "recentlySearched", object: recentlySearched)
        }
    }

    private func replaceWrapper(key: String, object: Any) {
        if let oldFileWrapper = fileWrapper.fileWrappers![key] {
            fileWrapper.removeFileWrapper(oldFileWrapper)
        }
        fileWrapper.addRegularFile(withContents: NSKeyedArchiver.archivedData(withRootObject: object),
                                   preferredFilename: key)
    }

    //MARK: OVERRIDING

    override func contents(forType typeName: String) throws -> Any {
        return NSKeyedArchiver.archivedData(withRootObject: fileWrapper)
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { return }
        let wrapper = NSKeyedUnarchiver.unarchiveObject(with: data) as? FileWrapper
        print(wrapper?.fileWrappers)
    }
}
