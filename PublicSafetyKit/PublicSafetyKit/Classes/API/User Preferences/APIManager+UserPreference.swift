//
//  APIManager+UserPreference.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

extension APIManager {
    
    /// Posts a preference request to the backend.
    ///
    /// - Parameter userPreference: preference request to post
    /// - Returns: voided promise as this remote call returns a 200 with an empty body
    public func storeUserPreference(_ userPreferenceRequest: UserPreferenceStoreRequest, path: String = "preference") -> Promise<Void> {
        return performRequest(userPreferenceRequest, pathTemplate: path, method: .post)
    }
    
    /// Fetches a user preference from a path using a UserPreferenceFetchRequest
    ///
    /// - Returns: A promise containing the resulting UserPreference
    public func fetchUserPreferences(with request: UserPreferenceFetchRequest, path: String = "preference") -> Promise<UserPreference> {
        return performRequest(request, pathTemplate: path, method: .get, parameterEncoding: URLEncoding.queryString)
    }
    
}

/// Wraps a request for a user preference
open class UserPreferenceFetchRequest: CodableRequestParameters {
    
    open var applicationName: String
    
    open var preferenceTypeKey: String
    
    public init(applicationName: String, preferenceTypeKey: UserPreferenceKey) {
        self.applicationName = applicationName
        self.preferenceTypeKey = preferenceTypeKey.rawValue
    }
    
}

/// Store request for a user preference.
public class UserPreferenceStoreRequest: CodableRequestParameters {
    public var applicationName: String
    //String here for auto synthesize
    public var preferenceTypeKey: String
    public var data: String
    public var mimeType: String
    
    public convenience init(_ userPreference: UserPreference) {
        self.init(applicationName: userPreference.applicationName,
                  preferenceTypeKey: userPreference.preferenceTypeKey.rawValue,
                  data: userPreference.data,
                  mimeType: userPreference.mimeType)
    }
    
    public init(applicationName: String = User.applicationKey, preferenceTypeKey: String, data: String, mimeType: String) {
        self.applicationName = applicationName
        self.preferenceTypeKey = preferenceTypeKey
        self.data = data
        self.mimeType = mimeType
    }
}

