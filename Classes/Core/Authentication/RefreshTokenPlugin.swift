//
//  RefreshTokenPlugin.swift
//  MPOLKit
//
//  Created by Megan Efron on 21/11/17.
//

import Alamofire
import PromiseKit


/// Plugin that checks responses for 401 and begins refresh logic:
///     - Creates a refresh promise that calls `APIManager.shared.refreshTokenRequest(..)`
///     - Chains all incoming adapt() requests to the refresh promise
///     - Chains all incoming processResponse() to the refresh promise with a new promise
///       that retries the request, and returns the new response
open class RefreshTokenPlugin: PluginType {
    

    // MARK: - Properties
    
    /// The paths that will be excluded from refresh logic.
    public let excludePaths: Set<String>
    
    /// Will execute if refresh token attempt fails (lets the app try to refresh session).
    public var onRefreshTokenFailed: ((Error?) -> Promise<Void>)?
    
    /// Will execute if every attempt fails (should end session and display login screen).
    public var onEverythingFailed: ((Error?) -> Void)?
    
    /// The promise that is currently executing the refresh token request.
    private var refreshPromise: Promise<Void>?
    
    
    // MARK: - Plugin Type
    
    public init(excludePaths: Set<String> = ["login", "refresh"]) {
        self.excludePaths = excludePaths
    }
    
    public func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        // Check for exclude paths
        if shouldExclude(urlRequest) {
            return Promise(value: urlRequest)
        }
        
        // If refresh is currently executing, chain returning the promise
        if let refresh = refreshPromise {
            return refresh.then {
                return Promise(value: urlRequest)
            }
        }
        
        // Return promise with request as normal
        return Promise(value: urlRequest)
    }
    
    public func processResponse(_ response: DataResponse<Data>) -> Promise<DataResponse<Data>> {
        // Check for exclude paths
        if shouldExclude(response.request) {
            return Promise(value: response)
        }
        
        // If refresh is currently executing, chain a retry of the request
        if let refresh = refreshPromise {
            return refresh.then { _ in
                // Retry original request
                return APIManager.shared.dataRequest(Promise(value: response.request!))
            }
        }
        
        // First instance of 401 response will begin refresh logic (all responses received
        // after the first 401 will be chained to the refresh promise created).
        if response.response?.statusCode == 401 {
            // If no refresh token exists, allow app to handle a failed refresh
            guard let token = UserSession.current.token?.refreshToken else {
                if let fallback = self.onRefreshTokenFailed {
                    // Begin refresh chain from the app's handler
                    self.refreshPromise = fallback(response.error)
                        .recover { error -> Void in
                            // Let app handle properly ending user session
                            self.onEverythingFailed?(error)
                            // Cancel all chained requests
                            throw NSError.cancelledError()
                        }.always {
                            self.refreshPromise = nil
                        }
                    
                    // Retry original request
                    return self.refreshPromise!.then {
                        return APIManager.shared.dataRequest(Promise(value: response.request!))
                    }
                } else {
                    onEverythingFailed?(response.error)
                    return Promise(error: NSError.cancelledError())
                }
            }
            
            // Create refresh promise
            self.refreshPromise = APIManager.shared.accessTokenRequest(for: .refreshToken(token))
                .then { token -> Void in
                    // Update access token
                    APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
                    UserSession.current.updateToken(token)
                }.recover { error -> Promise<Void> in
                    // Let app try refresh session
                    if let fallback = self.onRefreshTokenFailed {
                        return fallback(error)
                    }
                    throw error
                }.recover { error -> Void in
                    // Let app handle properly ending user session
                    self.onEverythingFailed?(error)
                    // Cancel all chained requests
                    throw NSError.cancelledError()
                }.always {
                    self.refreshPromise = nil
                }
            
            // Retry original request
            return refreshPromise!.then {
                return APIManager.shared.dataRequest(Promise(value: response.request!))
            }
        }
        
        // Return promise with response as normal
        return Promise(value: response)
    }
    
    // MARK: - Internal
    
    private func shouldExclude(_ request: URLRequest?) -> Bool {
        if let path = request?.url?.lastPathComponent {
            return excludePaths.contains(path)
        }
        return false
    }
}


// MARK: - Chaining methods

public extension RefreshTokenPlugin {
    
    @discardableResult
    public func onRefreshTokenFailed(_ onRefreshTokenFailed: ((Error?) -> Promise<Void>)?) -> Self {
        self.onRefreshTokenFailed = onRefreshTokenFailed
        return self
    }
    
    @discardableResult
    public func onEverythingFailed(_ onEverythingFailed: ((Error?) -> Void)?) -> Self {
        self.onEverythingFailed = onEverythingFailed
        return self
    }
    
}
