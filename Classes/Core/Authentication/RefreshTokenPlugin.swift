//
//  RefreshTokenPlugin.swift
//  MPOLKit
//
//  Created by Megan Efron on 21/11/17.
//

import Alamofire
import PromiseKit

open class RefreshTokenPlugin: PluginType {
    
    public typealias RefreshTokenFailedBlock = (Error?) -> Void
    
    // MARK: - Properties
    
    public var onRefreshTokenFailed: RefreshTokenFailedBlock?
    
    private var refreshPromise: Promise<Void>?
    
    public init() { }
    
    // MARK: - Plugin Type
    
    public func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        if let refresh = refreshPromise {
            return refresh.then {
                return Promise(value: urlRequest)
            }
        }
        return Promise(value: urlRequest)
    }
    
    public func processResponse(_ response: DataResponse<Data>) -> Promise<DataResponse<Data>> {
        if let refresh = refreshPromise {
            // Refresh token is currently executing
            return refresh.then { _ in
                // Retry original request
                return APIManager.shared.dataRequest(Promise(value: response.request!))
            }
        } else if response.response?.statusCode == 401 {
            guard let refreshToken = UserSession.current.token?.refreshToken else {
                onRefreshTokenFailed?(response.error)
                return Promise(value: response)
            }
            
            self.refreshPromise = APIManager.shared.accessTokenRequest(for: .refreshToken(refreshToken))
                .then { token -> Void in
                    APIManager.shared.authenticationPlugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: token))
                    UserSession.current.updateToken(token)
                }.catch { error in
                    self.onRefreshTokenFailed?(error)
                }.always {
                    self.refreshPromise = nil
                }
            
            return refreshPromise!.then {
                return APIManager.shared.dataRequest(Promise(value: response.request!))
            }
        } else {
            // Good to go
            return Promise(value: response)
        }
    }
}


public extension RefreshTokenPlugin {
    
    @discardableResult
    public func onRefreshTokenFailed(_ onRefreshTokenFailed: RefreshTokenFailedBlock?) -> Self {
        self.onRefreshTokenFailed = onRefreshTokenFailed
        return self
    }
    
}
