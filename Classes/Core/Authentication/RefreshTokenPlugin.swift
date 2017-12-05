//
//  RefreshTokenPlugin.swift
//  MPOLKit
//
//  Created by Megan Efron on 21/11/17.
//

import Alamofire
import PromiseKit


/// Plugin that checks responses for 401 and begins refresh logic:
///     - The app will provide a promise that handles refreshing token
///     - Chains all incoming adapt() requests to the refresh promise
///     - Chains all incoming processResponse() to the refresh promise with a new promise
///       that retries the request, and returns the new response
open class RefreshTokenPlugin: PluginType {
    
    /// This block will execute when a 401 is received, to create a promise that will
    /// re-authenticate the app. This should handle:
    /// - Refreshing the auth token
    /// - Updating the APIManager's authentication plugin
    /// - Handling any errors that are received and throwing them appropriately
    /// Keep in mind that network requests may be chained to this response, so correct error
    /// propogation is important, as the error you throw will be caught in the chain.
    public typealias RefreshHandler = (DataResponse<Data>) -> Promise<Void>

    // MARK: - Properties
    
    /// The paths that will be excluded from refresh logic.
    public let excludePaths: Set<String>
    
    /// Will execute on 401 to create a refresh attempt promise.
    public let refreshHandler: RefreshHandler
    
    /// The promise that is currently executing the refresh token request.
    private var refreshPromise: Promise<Void>? {
        get {
            var promise: Promise<Void>?
            barrierQueue.sync {
                promise = _refreshPromise
            }
            return promise
        }
        set {
            barrierQueue.async(flags: .barrier) { [weak self] in
                self?._refreshPromise = newValue
            }
        }
    }
    
    /// Internal promise protected by barrier. Use `refreshPromise` for thread safe access.
    private var _refreshPromise: Promise<Void>?
    
    /// Queue to get and set refresh promise ensuring thread safety.
    private let barrierQueue: DispatchQueue
    
    
    // MARK: - Plugin Type
    
    public init(excludePaths: Set<String> = ["login", "refresh"], _ refreshHandler: @escaping RefreshHandler) {
        self.refreshHandler = refreshHandler
        self.excludePaths = excludePaths
        self.barrierQueue = DispatchQueue(label: "au.com.gridstone.RefreshTokenPlugin.Barrier", attributes: .concurrent)
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
        // If request doesn't exist, then whatever I can't retry it anyway.
        guard let request = response.request else { return Promise(value: response) }
        
        // Check for exclude paths
        if shouldExclude(request) {
            return Promise(value: response)
        }
        
        // If refresh is currently executing, chain a retry of the request
        if let refresh = refreshPromise {
            return refresh.then { _ in
                // Reset headers & retry original request
                self.retry(request: request)
            }
        }
        
        // First instance of 401 response will begin refresh logic (all responses received
        // after the first 401 will be chained to the refresh promise created).
        if response.response?.statusCode == 401 {
            // First check if this response has come in after refresh has been executed
            if request.shouldUpdateAuthenticationHeader {
                return retry(request: request)
            }
            
            // Create refresh promise
            self.refreshPromise = firstly {
                // Let app attempt refresh
                return self.refreshHandler(response)
            }.always {
                self.refreshPromise = nil
            }
            
            // Reset headers & retry original request
            return self.refreshPromise!.then {
                return self.retry(request: request)
            }
        }
        
        // Return promise with response as normal
        return Promise(value: response)
    }
    
    // MARK: - Internal
    
    /// Checks for refresh token and executes refresh request if it exists, otherwise returns original error.
    private func tryRefreshToken(from response: DataResponse<Data>) -> Promise<Void> {
        // Reset auth plugin (because BE can't ignore headers)
        APIManager.shared.authenticationPlugin = nil
        
        // Create refresh token request with current token
        if let token = UserSession.current.token?.refreshToken {
            return APIManager.shared.accessTokenRequest(for: .refreshToken(token))
                .then { token -> Void in
                    // Update access token
                    APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
                    UserSession.current.updateToken(token)
                }.recover { error -> Promise<Void> in
                    // Throw 401 error instead of refresh token error
                    throw response.error!
            }
        }
        
        // Otherwise return 401 error
        return Promise(error: response.error!)
    }
    
    /// Determines whether request path is specified in `excludePaths`.
    private func shouldExclude(_ request: URLRequest?) -> Bool {
        if let path = request?.url?.lastPathComponent {
            return excludePaths.contains(path)
        }
        return false
    }
    
    /// Readapt request with new authentication plugin before retrying.
    private func retry(request: URLRequest) -> Promise<DataResponse<Data>> {
        return firstly {
            if request.shouldUpdateAuthenticationHeader, let plugin = APIManager.shared.authenticationPlugin {
                return plugin.adapt(request)
            } else {
                return Promise(value: request)
            }
        }.then { adapted in
            return APIManager.shared.dataRequest(Promise(value: adapted))
        }
    }

}


// MARK: - Auth Header Check

private extension URLRequest {
    
    var shouldUpdateAuthenticationHeader: Bool {
        guard let header = APIManager.shared.authenticationPlugin?.authenticationMode.authorizationHeader else { return false }
        return self.allHTTPHeaderFields?[header.key] != header.value
    }
}
