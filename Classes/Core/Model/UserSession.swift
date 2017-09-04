//
//  UserSession.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private let latestSessionKey = "LatestSessionKey"

public enum SessionError: Error {
    case alreadyBegun(String)
}

internal let archivingQueue = DispatchQueue(label: "MagicArchivingQueue")

public class UserSession: NSObject {

    public static let current = UserSession()
    public static var basePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

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
        }
        get {
            return self.document.user
        }
    }

    public var recentlyViewed: [MPOLKitEntity] {
        set {
            self.document.recentlyViewed = newValue
            saveSession()
        }
        get {
            return self.document.recentlyViewed
        }
    }

    public var recentlySearched: [Searchable] {
        set {
            self.document.recentlySearched = newValue
            saveSession()
        }
        get {
            return self.document.recentlySearched
        }
    }

    public var isActive: Bool {
        guard let _ = UserDefaults.standard.string(forKey: latestSessionKey) else { return false }
        return true
    }

    private lazy var document: UserSessionDocument = {
        let sessionID = UserDefaults.standard.string(forKey: latestSessionKey) ?? UUID().uuidString

        let url = UserSession.basePath
            .appendingPathComponent("sessions", isDirectory: true)
            .appendingPathComponent(sessionID)

        try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true,
                                                 attributes: [:])


        UserDefaults.standard.set(sessionID, forKey: latestSessionKey)

        return UserSessionDocument(fileURL: url)
    }()

    public func restoreSession(completion: @escaping ((Bool)->())) {
        document.open { success in
            completion(self.user != nil)
        }
    }

    public static func startSession(user: User,
                                    token: OAuthAccessToken,
                                    completion: @escaping (Bool)->())
    {
        UserSession.current.createSession() { success in
            UserSession.current.token = token
            UserSession.current.user = user
            UserSession.current.recentlyViewed = []
            UserSession.current.recentlySearched = []

            UserSession.current.loadUserFromCache()
            UserSession.current.saveUserToCache()

            completion(success)
        }
    }

    public func updateUser() {
        saveUserToCache()
    }

    public func endSession() {
        user = nil
        token = nil
        recentlySearched = []
        recentlyViewed = []
        UserDefaults.standard.set(nil, forKey: latestSessionKey)
    }

    public func renewSession(with token: OAuthAccessToken) {
        self.token = token
    }

    //MARK: SAVING

    private func createSession(completion: @escaping ((Bool)->())) {
        document.save(to: document.fileURL, for: .forCreating) { success in
            completion(success)
        }
    }

    private func saveSession() {
        document.save(to: document.fileURL, for: .forOverwriting)
    }

    private func saveUserToCache() {
        guard let username = user?.username else { return }
        let userDir = UserSession.basePath.appendingPathComponent("user", isDirectory: true)
        let fullUrl = userDir.appendingPathComponent(username)
        try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true, attributes: [:])

        archivingQueue.async { [weak self] in
            NSKeyedArchiver.archiveRootObject(self?.user, toFile: fullUrl.path)
        }

        document.updateUserReference()
        saveSession()
    }

    private func loadUserFromCache() {
        guard let username = user?.username else { return }
        let url = UserSession.basePath.appendingPathComponent("user").appendingPathComponent(username).path
        let possiblyActualUser = NSKeyedUnarchiver.unarchiveObject(withFile: url)

        if let validUser = possiblyActualUser as? User {
            self.user = validUser
            saveUserToCache()
        }
    }
}

fileprivate class UserSessionDocument: UIDocument {

    lazy var fileWrapper: FileWrapper = {
        let wrapper  = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.filename = "session"
        return wrapper
    }()

    var user: User?

    var token: OAuthAccessToken? {
        didSet {
            replaceWrapper(key: "token", object: token)
        }
    }

    var recentlyViewed: [MPOLKitEntity] = [] {
        didSet {
            replaceWrapper(key: "recentlyViewed", object: recentlyViewed)
        }
    }

    var recentlySearched: [Searchable] = [] {
        didSet {
            replaceWrapper(key: "recentlySearched", object: recentlySearched)
        }
    }

    private var previousUserWrapper: FileWrapper?

    private func replaceWrapper(key: String, object: Any) {
        if let oldFileWrapper = fileWrapper.fileWrappers![key] {
            fileWrapper.removeFileWrapper(oldFileWrapper)
        }
        fileWrapper.addRegularFile(withContents: NSKeyedArchiver.archivedData(withRootObject: object),
                                   preferredFilename: key)
    }

    func updateUserReference() {
        //Create symbolic link instead of direct wrapper
        guard let username = user?.username else { return }
        let url = UserSession.basePath.appendingPathComponent("user").appendingPathComponent(username)
        let userWrapper = FileWrapper(symbolicLinkWithDestinationURL: url)
        userWrapper.preferredFilename = "user"

        if let oldUserWrapper = previousUserWrapper {
            fileWrapper.removeFileWrapper(oldUserWrapper)
            previousUserWrapper = userWrapper
        }

        fileWrapper.addFileWrapper(userWrapper)
    }

    //MARK: OVERRIDING

    override func contents(forType typeName: String) throws -> Any {
        return fileWrapper
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let wrapper = contents as? FileWrapper else { return }
        guard let wrappers = wrapper.fileWrappers else { return }

        let userWrapper = wrappers["user"]
        let tokenWrapper = wrappers["token"]
        let recentlyViewedWrapper = wrappers["recentlyViewed"]
        let recentlySearchedWrapper = wrappers["recentlySearched"]

        let first = (userWrapper?.symbolicLinkDestinationURL?.deletingLastPathComponent().lastPathComponent)!
        let second = (userWrapper?.symbolicLinkDestinationURL?.lastPathComponent)!

        let userPath = UserSession.basePath.appendingPathComponent(first).appendingPathComponent(second)

        let user = NSKeyedUnarchiver.unarchiveObject(withFile: userPath.path) as? User
        let token = NSKeyedUnarchiver.unarchiveObject(with: (tokenWrapper?.regularFileContents)!) as? OAuthAccessToken
        let recentlyViewed = NSKeyedUnarchiver.unarchiveObject(with: (recentlyViewedWrapper?.regularFileContents)!) as! [MPOLKitEntity]
        let recentlySearched = NSKeyedUnarchiver.unarchiveObject(with: (recentlySearchedWrapper?.regularFileContents)!) as! [Searchable]
        
        self.user = user
        self.token = token
        self.recentlyViewed = recentlyViewed
        self.recentlySearched = recentlySearched
    }
}
