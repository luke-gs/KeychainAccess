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
    
    public init() { }
    

    // MARK: - Properties
    
    /// Block that will execute if refresh token fails. (i.e. end session and display login screen)
    public var onRefreshTokenFailed: ((Error?) -> Void)?
    
    /// The paths that will be excluded in the plugin.
    public var excludePaths: Set<String> = ["login", "refresh"]
    
    /// The promise that is currently executing the refresh token request.
    private var refreshPromise: Promise<Void>?
    
    
    // MARK: - Plugin Type
    
    public func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        // Check for exclude paths
        if let path = urlRequest.url?.lastPathComponent, excludePaths.contains(path) {
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
        if let path = response.request?.url?.lastPathComponent, excludePaths.contains(path) {
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
            guard let refreshToken = UserSession.current.token?.refreshToken else {
                onRefreshTokenFailed?(response.error)
                return Promise(value: response)
            }
            
            // Create refresh promise
            self.refreshPromise = APIManager.shared.refreshTokenRequest(for: refreshToken)
                .then { token -> Void in
                    // Update access token
                    APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
                    UserSession.current.updateToken(token)
                }.catch { error in
                    // Allow app to handle fallback
                    self.onRefreshTokenFailed?(error)
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
}


// MARK: - Chaining methods

public extension RefreshTokenPlugin {
    
    @discardableResult
    public func excludePaths(_ excludePaths: Set<String>) -> Self {
        self.excludePaths = excludePaths
        return self
    }
    
    @discardableResult
    public func onRefreshTokenFailed(_ onRefreshTokenFailed: ((Error?) -> Void)?) -> Self {
        self.onRefreshTokenFailed = onRefreshTokenFailed
        return self
    }
    
}
