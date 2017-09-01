//
//  UserSession.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private let AuthTokenDirectoryKey = "AuthToken"
private let RecentlySearchedDirectoryKey = "RecentlySearched"
private let RecentlyViewedDirectoryKey = "RecentlyViewed"
private let MostRecentUserDirectoryKey = "MostRecentUser"
private let AuthTokenInfoKey = "AuthTokenInfo"

public enum SessionError: Error {
    case alreadyBegun(String)
}

internal let archivingQueue = DispatchQueue(label: "MagicArchivingQueue")

public class UserSession: NSObject {

    private(set) internal var basePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private(set) internal var token: OAuthAccessToken?

    private(set) public var user: User? {
        didSet {
            guard let user = user, oldValue !== user else { return }
            restoreUser()
        }
    }

    public var info: [String: String]? {
        get {
            return restoreInfo()
        }
    }

    public var recentlyViewed: [MPOLKitEntity]? = [] {
        didSet {
            guard let oldValue = oldValue, let recentlyViewed = recentlyViewed, oldValue != recentlyViewed else { return }
            saveViewed()
        }
    }

    public var recentlySearched: [Searchable]? = [] {
        didSet {
            guard let oldValue = oldValue, let recentlySearched = recentlySearched, oldValue != recentlySearched else { return }
            saveSearched()
        }
    }

    public static let current = UserSession()

    public static func startSession(user: User,
                                    token: OAuthAccessToken,
                                    basePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!) throws
    {
        guard UserSession.current.user == nil
            else { throw SessionError.alreadyBegun("Session in progress for user: \(UserSession.current.user!.username)") }
        UserSession.current.user = user
        UserSession.current.token = token

        UserSession.current.saveUser()
        UserSession.current.saveSession()
    }

    public func endSession() {
        user = nil
        token = nil
        recentlySearched = nil
        recentlyViewed = nil
    }

    public func renewSession(with token: OAuthAccessToken) {
        self.token = token
        self.recentlySearched = NSKeyedUnarchiver.unarchiveObject(withFile: path(for: RecentlySearchedDirectoryKey)) as! [Searchable]?
        self.recentlyViewed = NSKeyedUnarchiver.unarchiveObject(withFile: path(for: RecentlyViewedDirectoryKey)) as! [MPOLKitEntity]?
        saveSession()
    }

    //MARK: SAVING

    private func saveUser() {
        archivingQueue.async { [unowned self] in
            self.user?.save(to: self.basePath)
        }
    }

    private func saveSession() {
        saveToken()
        saveViewed()
        saveSearched()
    }

    private func saveViewed() {
        archivingQueue.async { [unowned self] in
            NSKeyedArchiver.archiveRootObject(self.recentlyViewed ?? [], toFile: self.path(for: RecentlyViewedDirectoryKey))
        }
    }

    private func saveSearched() {
        archivingQueue.async { [unowned self] in
            NSKeyedArchiver.archiveRootObject(self.recentlySearched ?? [], toFile: self.path(for: RecentlySearchedDirectoryKey))
        }
    }

    private func saveToken() {
        archivingQueue.async { [unowned self] in
            //FIXME: Save to keychain
            NSKeyedArchiver.archiveRootObject(self.token, toFile: self.path(for: AuthTokenDirectoryKey))
        }
    }

    private func saveInfo() {
        archivingQueue.async { [unowned self] in
            let info = ["id": UUID().uuidString]
            NSKeyedArchiver.archiveRootObject(info, toFile: self.path(for: AuthTokenInfoKey))
        }
    }

    //MARK: RESTORING

    private func restoreSession() {
        restoreToken()
        restoreViewed()
        restoreSearched()
    }

    private func restoreInfo() -> [String: String]? {
        guard let info = NSKeyedUnarchiver.unarchiveObject(withFile: path(for: AuthTokenInfoKey)) as? [String: String] else { return nil }
        return info
    }

    private func restoreViewed() {

    }

    private func restoreSearched() {

    }

    private func restoreToken() {

    }
    private func restoreMostRecentUser() {

    }

    private func restoreUser() {
        guard let username = user?.username else { return }
        let path = basePath.appendingPathComponent("\(UserDirectoryKey)").appendingPathComponent("\(username)").path
        guard let user = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? User else { return }
        self.user = user
    }

    private func path(for file: String) -> String {
        return basePath.appendingPathComponent(file).path
    }
}
