//
//  RefreshTokenPlugin.swift
//  MPOLKit
//
//  Created by Megan Efron on 21/11/17.
//

import Alamofire
import PromiseKit

open class RefreshTokenPlugin: PluginType {
    
    public typealias RefreshTokenFailedBlock = (Alamofire.DataResponse<Data>) -> Void
    
    // MARK: - Properties
    
    public var onRetryFailed: RefreshTokenFailedBlock?
    
    private var refreshPromise: Promise<DataResponse<Data>>?
    
    public init() { }
    
    // MARK: - Plugin Type
    
    public func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
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
            // TODO: Refresh token here, retry & set refresh promise to nil
            return Promise(value: response)
        } else {
            // Good to go
            return Promise(value: response)
        }
    }
}


public extension RefreshTokenPlugin {
    
    @discardableResult
    public func onRetryFailed(_ onRetryFailed: RefreshTokenFailedBlock?) -> Self {
        self.onRetryFailed = onRetryFailed
        return self
    }
    
}
