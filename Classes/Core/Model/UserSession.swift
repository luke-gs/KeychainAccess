//
//  UserSession.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

protocol UserSessionable: class {
    var user: User { get }
    var token: OAuthAccessToken { get }
}

class UserSession: NSObject, UserSessionable {
    var user: User
    var token: OAuthAccessToken
    var recentlyViewed: [MPOLKitEntity]?
    var recentlySearched: [Searchable]?

    init(user: User, token: OAuthAccessToken) {
        self.user = user
        self.token = token
        super.init()
    }
}
