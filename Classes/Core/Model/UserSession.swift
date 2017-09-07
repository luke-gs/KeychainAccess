//
//  UserSession.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import KeychainSwift

private struct UserSessionPaths {

    private let basePath: URL
    private let sessionId: String


    init(baseUrl: URL, sessionId: String) {
        self.basePath = baseUrl
        self.sessionId = sessionId
    }

    var session: String {
        let array = ["session", "\(sessionId)"]
        return array.joined(separator: "/")
    }

    var recentlyViewed: String {
        let array = ["session", "\(sessionId)", "viewed"]
        return array.joined(separator: "/")
    }

    var recentlySearched: String {
        let array = ["session", "\(sessionId)", "searched"]
        return array.joined(separator: "/")
    }

    var userWrapperPath: String {
        let array = ["session", "\(sessionId)", "user"]
        return array.joined(separator: "/")
    }

    func userPath(for name: String) -> String {
        let array = ["user", "\(name)"]
        return array.joined(separator: "/")
    }
}

public class UserSession: UserSessionable {

    public static let current = UserSession()
    public static var basePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private(set) public var token: OAuthAccessToken? {
        get {
            guard let data = keychain.getData("token") else { return nil }
            return (NSKeyedUnarchiver.unarchiveObject(with: data) as! OAuthAccessToken)
        }
        set {
            if let token = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: token)
                keychain.set(data, forKey: "token")
            } else {
                keychain.delete("token")
            }
        }
    }

    private(set) public var user: User?

    public var recentlyViewed: [MPOLKitEntity] = [] {
        didSet {
            directoryManager.write(recentlyViewed, to: paths.recentlyViewed)
        }
    }

    public var recentlySearched: [Searchable] = [] {
        didSet {
            directoryManager.write(recentlySearched, to: paths.recentlySearched)
        }
    }

    public var isActive: Bool {
        guard let _ = UserDefaults.standard.string(forKey: latestSessionKey) else { return false }
        return true
    }

    public var sessionID: String {
        let sessionID = UserDefaults.standard.string(forKey: latestSessionKey) ?? UUID().uuidString
        UserDefaults.standard.set(sessionID, forKey: latestSessionKey)
        return sessionID
    }

    public static func startSession(user: User,
                                    token: OAuthAccessToken,
                                    completion: @escaping UserSessionCompletion)
    {
        UserSession.current.token = token
        UserSession.current.user = user
        UserSession.current.recentlyViewed = []
        UserSession.current.recentlySearched = []

        UserSession.current.loadUserFromCache()
        UserSession.current.saveUserToCache()

        completion(true)
    }

    public func updateUser() {
        saveUserToCache()
    }

    public func endSession() {
        try! directoryManager.remove(at: paths.session)
        UserDefaults.standard.set(nil, forKey: latestSessionKey)
    }

    public func restoreSession(completion: @escaping UserSessionCompletion) {
        let userWrapper = directoryManager.read(from: paths.userWrapperPath) as? FileWrapper
        let viewed = directoryManager.read(from: paths.recentlyViewed) as! [MPOLKitEntity]
        let searched = directoryManager.read(from: paths.recentlySearched) as! [Searchable]

        guard userWrapper != nil else {
            UserSession.current.endSession()
            return
        }

        let first = (userWrapper?.symbolicLinkDestinationURL?.deletingLastPathComponent().lastPathComponent)!
        let second = (userWrapper?.symbolicLinkDestinationURL?.lastPathComponent)!
        let userPath = UserSession.basePath.appendingPathComponent(first).appendingPathComponent(second)

        self.user = NSKeyedUnarchiver.unarchiveObject(withFile: userPath.path) as? User
        self.recentlyViewed = viewed
        self.recentlySearched = searched

        completion(true)
    }

    //MARK: PRIVATE
    private let keychain = KeychainSwift()
    private lazy var directoryManager = {
        return DirectoryManager(baseURL: UserSession.basePath)
    }()
    private lazy var paths: UserSessionPaths = {
        return UserSessionPaths(baseUrl: UserSession.basePath, sessionId: self.sessionID)
    }()

    //MARK: SAVING

    private func saveUserToCache() {
        //Archive user
        guard let user = user else { return }
        directoryManager.write(user, to: paths.userPath(for: user.username))

        //Add symbolic link to session
        guard let url = URL(string: paths.userPath(for: user.username)) else { return }
        let userWrapper = FileWrapper(symbolicLinkWithDestinationURL: url)
        userWrapper.preferredFilename = "user"
        directoryManager.write(userWrapper, to: paths.userWrapperPath)
    }

    //MARK: RESTORING

    private func loadUserFromCache() {
        guard let username = user?.username else { return }
        let possiblyActualUser = directoryManager.read(from: paths.userPath(for: username))

        if let validUser = possiblyActualUser as? User {
            user = validUser
            saveUserToCache()
        }
    }
}

private let latestSessionKey = "LatestSessionKey"
private let archivingQueue = DispatchQueue(label: "MagicArchivingQueue")

/// Generic user session completion closure
public typealias UserSessionCompletion = ((_ success: Bool)->())

/// Protocol for the user session. (Mainly for clean docs)
public protocol UserSessionable {

    /// The current user session
    static var current: UserSession { get }

    /// The base path to save everything to
    static var basePath: URL { get set }

    /// Create and start a new session
    ///
    /// - Parameters:
    ///   - user: the user object for the session
    ///   - token: the OAuth token for the session
    ///   - completion: completion when all necessary data has been written to disk, and session is created. True is successful
    static func startSession(user: User, token: OAuthAccessToken, completion: @escaping UserSessionCompletion)

    /// The user for the session
    var user: User? { get }

    /// The recently viewed entities for this session
    var recentlyViewed: [MPOLKitEntity] { get set }

    /// The recently searched entities for this session
    var recentlySearched: [Searchable] { get set }

    /// Whether the session is active
    var isActive: Bool { get }

    /// The session unique ID
    var sessionID: String { get }

    /// Attempt to restore a previous session
    ///
    /// - Parameter completion: completion when all necessary data has read from disk and session was restored. True is successful
    func restoreSession(completion: @escaping UserSessionCompletion)

    /// Call this when any changes to the user had been made.
    /// Currently only called when t&cs and whatsNew have been updated
    func updateUser()

    /// End the session - effectively signing the user out.
    ///
    /// **note:** calling this does not update the UI.
    func endSession()
}

