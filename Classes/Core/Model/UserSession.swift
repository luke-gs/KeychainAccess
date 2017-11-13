//
//  UserSession.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import KeychainSwift

public class UserSession: UserSessionable {

    public static let latestSessionKey = "LatestSessionKey"

    public static let current = UserSession()
    private(set) var token: OAuthAccessToken?
    private(set) public var user: User?

    // Use the app group base path for sharing between apps by default
    public static var basePath: URL = AppGroup.appBaseFilePath()

    // Use the app group user defaults for sharing between apps by default
    public static var userDefaults: UserDefaults = AppGroup.appUserDefaults()

    public var recentlyViewed: [MPOLKitEntity] = [] {
        didSet {
            directoryManager.write(recentlyViewed as NSArray, to: paths.recentlyViewed)
        }
    }

    public var recentlySearched: [Searchable] = [] {
        didSet {
            directoryManager.write(recentlySearched as NSArray, to: paths.recentlySearched)
        }
    }

    public var isActive: Bool {
        return UserSession.userDefaults.string(forKey: UserSession.latestSessionKey) != nil
    }

    public var sessionID: String {
        let sessionID = UserSession.userDefaults.string(forKey: UserSession.latestSessionKey) ?? UUID().uuidString
        UserSession.userDefaults.set(sessionID, forKey: UserSession.latestSessionKey)
        return sessionID
    }

    public static func startSession(user: User, token: OAuthAccessToken) {
        UserSession.current.paths = UserSessionPaths(baseUrl: UserSession.basePath, sessionId: UserSession.current.sessionID)
        
        UserSession.current.token = token
        UserSession.current.user = user
        UserSession.current.recentlyViewed = []
        UserSession.current.recentlySearched = []

        UserSession.current.saveTokenToKeychain()
        UserSession.current.loadUserFromCache()
        UserSession.current.saveUserToCache()
    }

    public func updateUser() {
        saveUserToCache()
    }

    public func endSession() {
        UserSession.userDefaults.removeObject(forKey: UserSession.latestSessionKey)

        user = nil
        token = nil
        recentlyViewed = []
        recentlySearched = []
        directoryManager.write(nil, toKeyChain: "token")

        try! directoryManager.remove(at: paths.session)
    }

    public func isTokenValid() -> Bool {
        return directoryManager.read(fromKeyChain: "token") != nil
    }

    public func restoreSession(completion: @escaping RestoreSessionCompletion) {
        let userWrapper = directoryManager.read(from: paths.userWrapperPath) as? FileWrapper
        let viewed = directoryManager.read(from: paths.recentlyViewed) as? [MPOLKitEntity] ?? []
        let searched = directoryManager.read(from: paths.recentlySearched) as? [Searchable] ?? []

        var token: OAuthAccessToken?

        //For testing purposes
        if !TestingDirective.isTesting {
            token = directoryManager.read(fromKeyChain: "token") as? OAuthAccessToken
            self.token = token
        }

        guard userWrapper != nil else {
            UserSession.current.endSession()
            return
        }

        //Documents directory will change so can't rely on absolute path
        let first = (userWrapper?.symbolicLinkDestinationURL?.deletingLastPathComponent().lastPathComponent)!
        let second = (userWrapper?.symbolicLinkDestinationURL?.lastPathComponent)!
        let userPath = UserSession.basePath.appendingPathComponent(first).appendingPathComponent(second)

        self.user = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(from: userPath.path)
        self.recentlyViewed = viewed
        self.recentlySearched = searched

        if let token = self.token, self.user != nil {
            completion(token)
        } else {
            completion(OAuthAccessToken(accessToken: "", type: ""))
        }
    }

    //MARK: PRIVATE

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

    private func saveTokenToKeychain() {
        directoryManager.write(token, toKeyChain: "token")
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

/// Restoring user session closure, returns auth token when complete
public typealias RestoreSessionCompletion = ((_ token: OAuthAccessToken)->())

public struct UserSessionPaths {

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
    static func startSession(user: User, token: OAuthAccessToken)

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
    /// - Parameter completion: completion when all necessary data has read from disk and session was restored. Returns the token.
    func restoreSession(completion: @escaping RestoreSessionCompletion)

    /// Call this when any changes to the user had been made.
    /// Currently only called when t&cs and whatsNew have been updated
    func updateUser()

    /// End the session - effectively signing the user out.
    ///
    /// **note:** calling this does not update the UI.
    func endSession()
}
