//
//  CADUserSession.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public extension NSNotification.Name {

    /// Notification posted when callsign status changes
    static let CallsignChanged = NSNotification.Name(rawValue: "MPOLKit_CallsignChanged")
}

/// CAD specific user session
public class CADUserSession {

    /// The current user session
    public static let current = CADUserSession()

    /// The current auth token, or nil
    private(set) public var token: OAuthAccessToken?

    /// The current user, or nil
    private(set) public var user: User?

    /// The currently booked on callsign, or nil
    public var callsign: String? {
        didSet {
            NotificationCenter.default.post(name: .CallsignChanged, object: self)
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

    public func isTokenValid() -> Bool {
        return directoryManager.read(fromKeyChain: "token") != nil
    }

    public func restoreSession(completion: @escaping RestoreSessionCompletion) {
        let paths = UserSessionPaths(baseUrl: UserSession.basePath, sessionId: sessionID)
        let userWrapper = directoryManager.read(from: paths.userWrapperPath) as? FileWrapper
        var token: OAuthAccessToken?

        // For testing purposes
        if !TestingDirective.isTesting {
            token = directoryManager.read(fromKeyChain: "token") as? OAuthAccessToken
            self.token = token
        }

        // Documents directory will change so can't rely on absolute path
        let first = (userWrapper?.symbolicLinkDestinationURL?.deletingLastPathComponent().lastPathComponent)!
        let second = (userWrapper?.symbolicLinkDestinationURL?.lastPathComponent)!
        let userPath = UserSession.basePath.appendingPathComponent(first).appendingPathComponent(second)

        self.user = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(from: userPath.path)

        completion(self.token ?? OAuthAccessToken(accessToken: "", type: ""))
    }

    // MARK: - Private

    private lazy var directoryManager = {
        return DirectoryManager(baseURL: UserSession.basePath)
    }()
}

