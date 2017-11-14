//
//  OAuth2.swift
//  MPOLKit
//
//  Created by Herli Halim on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//


import PromiseKit
import Unbox

open class OAuth2: AuthenticationProvider {

    public typealias Result = OAuth2GrantResult

    public let clientId: String

    public let authorizationEndpoint: URL

    public let redirectURL: URL

    public let grantType: OAuth2GrantType

    public let state: String

    public let scopes: Set<String>

    /// Returns a URL by composing the `authorizationEndpoint` with `requestParameters` as `URLQueryItems`.
    public var authorizationURL: URL {
        var authorizationURL = URLComponents(url: authorizationEndpoint, resolvingAgainstBaseURL: false)!

        authorizationURL.queryItems = requestParameters.flatMap({ URLQueryItem(name: $0.key, value: $0.value) })

        return authorizationURL.url!
    }

    public var urlScheme: String {
        return redirectURL.scheme!
    }

    /// The default init. `state` will default to UUID if not provided.
    public init(clientId: String, authorizationEndpoint: URL, redirectURL: URL, grantType: OAuth2GrantType, scopes: Set<String>, state: String = UUID().uuidString) {
        self.clientId = clientId
        self.authorizationEndpoint = authorizationEndpoint
        self.redirectURL = redirectURL
        self.grantType = grantType
        self.state = state
        self.scopes = scopes
    }

    public func authenticationLinkResult(_ url: URL) -> Promise<Result> {

        guard let  urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return Promise(error: ParsingError.missingRequiredField)
        }

        let queryItems = urlComponents.queryItems

        let queryDict: [String: String]

        if let queryItems = queryItems {
            var dict = [String: String]()
            queryItems.forEach {
                dict[$0.name] = $0.value
            }
            queryDict = dict
        } else {
            queryDict = [:]
        }

        let result: OAuth2GrantResult

        switch grantType {
        case .authorizationCode:
            let key = OAuth2GrantType.authorizationCode.rawValue
            guard let code = queryDict[key] else {
                // Missing field error goes here
                return Promise(error: OAuth2ResultError.missingRequiredField(key))
            }
            result = .authorizationCode(code: code)
        case .implicit:
            let key = OAuth2GrantType.implicit.rawValue
            guard queryDict[key] != nil else {
                // Missing field error goes here
                return Promise(error: OAuth2ResultError.missingRequiredField(key))
            }

            do {
                let accessToken: OAuthAccessToken = try unbox(dictionary: queryDict)
                result = .implicit(token: accessToken)
            } catch {
                return Promise(error: error)
            }
        case .custom:
            result = .custom(result: queryDict)
        }

        return Promise(value: result)
    }


    /// Create the authorization request parameters. Override this to allow more parameters
    /// in subclasses.
    ///
    /// - Returns: A dictionary with keys and values of String type.
    open var requestParameters: [String: String] {
        return [ "client_id": clientId,
                 "redirect_uri": redirectURL.absoluteString,
                 "response_type": grantType.rawValue,
                 "scope": scopes.joined(separator: " "),
                 "state": state ]
    }

}

public enum OAuth2ResultError: Error {
    case missingRequiredField(String)
}

public enum OAuth2GrantType: String {
    case authorizationCode = "code"
    case implicit = "token"
    case custom = "custom"
}

public enum OAuth2GrantResult {
    case authorizationCode(code: String)
    case implicit(token: OAuthAccessToken)
    case custom(result: [String: String])
}
