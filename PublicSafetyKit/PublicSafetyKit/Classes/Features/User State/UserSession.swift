//
//  UserSession.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import KeychainAccess

public extension NSNotification.Name {
    /// Notification posted when user session starts
    static let userSessionStarted = NSNotification.Name(rawValue: "UserSessionStarted")
    
    /// Notification posted when user session starts
    static let userSessionEnded = NSNotification.Name(rawValue: "UserSessionEnded")
}

public class UserSession: UserSessionable {

    public static let latestSessionKey      = "LatestSessionKey"
    public static let recentIdsKey          = "RecentIdsKey"
    public static let currentOfficerKey     = "currentOfficer"

    public static let current = UserSession()
    private(set) public var token: OAuthAccessToken?
    private(set) public var user: User?
    private(set) public var userStorage: UserStorage?
    
    // Use the app group base path for sharing between apps by default
    public static var basePath: URL = AppGroupCapability.appBaseFilePath

    // Use the app group user defaults for sharing between apps by default
    public static var userDefaults: UserDefaults = AppGroupCapability.appUserDefaults

    public var recentlyViewed: EntityBucket = EntityBucket(limit: 6)

    public var recentlySearched: [Searchable] = [] {
        didSet {
            directoryManager.write(recentlySearched as NSArray, to: paths.recentlySearched)
        }
    }

    public var isActive: Bool {
        // Note: during login we will briefly have a session ID without a started session.
        // If you need to know if session is started, check for a current user or token
        return sessionID != nil
    }

    public private(set) var sessionID: String? {
        get {
            let sessionID = UserSession.userDefaults.string(forKey: UserSession.latestSessionKey)
            return sessionID
        }
        set {
            UserSession.userDefaults.set(newValue, forKey: UserSession.latestSessionKey)
        }
    }

    private var isRestoringSession: Bool = false

    public init() {
        // Backwards compatibility for loading users that were stored when class was in different module
        NSKeyedUnarchiver.setClass(User.self, forClassName: "MPOLKit.User")

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleRecentlyViewedChanged), name: EntityBucket.didUpdateNotificationName, object: recentlyViewed)
    }

    /// Prepare for a new session, setup any required headers for authentication
    public static func prepareForSession() {
        let sessionID = UUID().uuidString
        UserSession.current.sessionID = sessionID
    }

    public static func startSession(user: User, token: OAuthAccessToken) {
        // Should already have a session ID by this point, but use fallback for older clients
        let sessionID = UserSession.current.sessionID ?? UUID().uuidString
        UserSession.current.sessionID = sessionID

        UserSession.current.paths = UserSessionPaths(baseUrl: UserSession.basePath, sessionId: sessionID)
        UserSession.current.token = token
        UserSession.current.user = user
        UserSession.current.recentlySearched = []
        UserSession.current.userStorage = UserStorage(userID: user.username)

        UserSession.current.saveTokenToKeychain()
        UserSession.current.loadUserFromCache()
        UserSession.current.saveUserToCache()
        
        NotificationCenter.default.post(name: .userSessionStarted, object: nil)
    }
    
    public func updateToken(_ token: OAuthAccessToken?) {
        self.token = token
        saveTokenToKeychain()
    }

    public func updateUser() {
        saveUserToCache()
    }

    public func endSession() {
        // Clear session ID
        sessionID = nil

        // Perform further cleanup if session was actually started
        if paths != nil {
            user = nil
            token = nil
            recentlySearched = []
            recentlyViewed.removeAll()
            userStorage = nil
            directoryManager.write(nil, toKeyChain: "token")

            try! directoryManager.remove(at: paths.session)
            NotificationCenter.default.post(name: .userSessionEnded, object: nil)
        }
    }

    public func isTokenValid() -> Bool {
        return directoryManager.read(fromKeyChain: "token") != nil
    }

    public func restoreSession(completion: @escaping RestoreSessionCompletion) {
        isRestoringSession = true

        // Can't restore if there's any session to begin with..
        guard let sessionID = UserSession.current.sessionID else {
            UserSession.current.endSession()
            return
        }

        // Recreate paths, as session ID may have changed in another app
        paths = UserSessionPaths(baseUrl: UserSession.basePath, sessionId: sessionID)

        let directoryManager = self.directoryManager

        guard let userWrapper = directoryManager.read(from: paths.userWrapperPath) as? FileWrapper else {
            UserSession.current.endSession()
            return
        }

        // Currently, these 2 are sessions based only. So when they fail to deserialise
        // which most of the cases are just due to not migrating data, it'll just empty it out instead
        // of crashing.
        var viewed: [MPOLKitEntity] = []
        var searched: [Searchable] = []
        let recentlyViewedPath = paths.recentlyViewed
        let recentlySearchedPath = paths.recentlySearched

        try? ObjC.catchException {
            if let read = directoryManager.read(from: recentlyViewedPath) as? [MPOLKitEntity] {
                viewed = read
            }
            if let read = directoryManager.read(from: recentlySearchedPath) as? [Searchable] {
                searched = read
            }
        }

        var token: OAuthAccessToken?

        //For testing purposes
        if !TestingDirective.isTesting {
            token = directoryManager.read(fromKeyChain: "token") as? OAuthAccessToken
            self.token = token
        }

        //Documents directory will change so can't rely on absolute path
        let first = (userWrapper.symbolicLinkDestinationURL?.deletingLastPathComponent().lastPathComponent)!
        let second = (userWrapper.symbolicLinkDestinationURL?.lastPathComponent)!
        let userPath = UserSession.basePath.appendingPathComponent(first).appendingPathComponent(second)

        self.user = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(from: userPath.path)
        self.recentlySearched = searched

        recentlyViewed.removeAll()
        recentlyViewed.add(viewed)

        isRestoringSession = false

        // Load recent IDs for user if found
        if let user = self.user {
            UserSession.current.userStorage = UserStorage(userID: user.username)
        }

        if let token = self.token {
            completion(token)
        } else {
            completion(OAuthAccessToken(accessToken: "", type: ""))
        }
        
        NotificationCenter.default.post(name: .userSessionStarted, object: nil)
    }

    //MARK: PRIVATE

    private lazy var directoryManager = {
        return DirectoryManager(baseURL: UserSession.basePath)
    }()

    // Risky business, I know, so fix please.
    // Although it's better to crash than what it was previously,
    // SessionID being generated randomly. It gets app to weird state if the lazy var was to ever accessed
    // in the wrong order. So instead of weird state, it will crash. If it crashes, then it needs to be fixed.
    private var paths: UserSessionPaths!

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

    @objc private func handleRecentlyViewedChanged() {
        guard !isRestoringSession else { return }
        directoryManager.write(recentlyViewed.entities as NSArray, to: paths.recentlyViewed)
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

    // MARK: - User data

    // FIXME: - User and UserSession data should be separated.
    // This is in to be able to load `User.appSettings` in the mean time.
    public static func loadUser(username: String) -> User? {
        let session = UserSession()
        // This is broken, I hope this becomes ugly enough that someone will say
        // F this, not in sprint, but I'll fix this `UserSession` and `User data` coupling.
        let path = UserSessionPaths(baseUrl: UserSession.basePath, sessionId: "hello:)") // For user, sessionId doesn't matter.
        let user: User
        if let savedUser = session.directoryManager.read(from: path.userPath(for: username)) as? User {
            user = savedUser
        } else {
            // Create and save user
            user = User(username: username)
            UserSession.save(user: user)
        }
        return user
    }

    // This is in to be able to save `User.appSettings` in the mean time.
    // Note: This will overwrite the user data, not append. 
    public static func save(user: User) {
        let session = UserSession()
        session.paths = UserSessionPaths(baseUrl: UserSession.basePath, sessionId: "hello:)") // For user, sessionId doesn't matter.
        session.user = user
        session.saveUserToCache()
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
    var recentlyViewed: EntityBucket { get }

    /// The recently searched entities for this session
    var recentlySearched: [Searchable] { get set }

    /// Whether the session is active
    var isActive: Bool { get }

    /// The session unique ID
    var sessionID: String? { get }

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
