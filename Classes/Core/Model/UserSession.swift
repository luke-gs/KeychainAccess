//
//  UserSession.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol Sessionable: class {
    var user: User? { get }
    var token: OAuthAccessToken? { get }

    var filePath: URL { get set }
    var recentlyViewed: [MPOLKitEntity]? { get set }
    var recentlySearched: [Searchable]? { get set }

    static func startSession(user: User, token: OAuthAccessToken) throws

    func stopSession()
    func renewSession()
}

public enum SessionError: Error {
    case alreadyStarted(message: String)
}

public class UserSession: NSObject, Sessionable {
    private(set) public var user: User?
    private(set) public var token: OAuthAccessToken?

    public var filePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    public var recentlyViewed: [MPOLKitEntity]? = []
    public var recentlySearched: [Searchable]? = []

    public static let current = UserSession()

    public static func startSession(user: User, token: OAuthAccessToken) throws {
        guard UserSession.current.user == nil else { throw SessionError.started(message: "Session already started") }
        UserSession.current.user = user
        UserSession.current.token = token
    }

    public func stopSession() {
        token = nil
        recentlySearched = nil
        recentlyViewed = nil
    }

    public func renewSession() {

    }
}
