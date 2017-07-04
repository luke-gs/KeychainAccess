//
//  URLJSONRequestOperation.swift
//  MPOLKit
//
//  Created by Rod Brown on 7/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

/// A `URLRequestOperation` for conducting json requests with a remote server.
///
/// `URLJSONRequestOperation` lazily loads its request during execution from
/// the specified session manager.
open class URLJSONRequestOperation: URLRequestOperation, HasDataResponse {
    
    // MARK: - Properties
    
    /// The underlying url request.
    open private(set) var urlRequest: URLRequestConvertible
    
    
    /// The session manager. This session is responsible for creating the request
    /// at execution time.
    open let sessionManager: SessionManager
    
    
    /// The request for the operation. Setting this value on `URLJSONRequestOperation`
    /// is a no-op as the operation internally manages its own request.
    open override var request: Request? {
        get { return super.request }
        set { /* Nop */ }
    }
    
    
    /// The response from the server. This is set once the request has been processed.
    open private(set) var response: DataResponse<Any>?
    
    
    // MARK: - Initializers
    
    /// The designated initializer for `URLJSONRequestOperation`s.
    ///
    /// - Parameters:
    ///   - urlRequest:     The URL request to perform.
    ///   - sessionManager: The session manager responsible for the request.
    public init(urlRequest: URLRequestConvertible, sessionManager: SessionManager = .default) {
        self.urlRequest     = urlRequest
        self.sessionManager = sessionManager
        super.init()
    }
    
    
    /// A convenience initializer for creating a `URLJSONRequestOperation` with
    /// the basic components of a request.
    ///
    /// - Parameters:
    ///   - url:            The URL for the request.
    ///   - method:         The `HTTPMethod` to perform. The default is `.get`.
    ///   - parameters:     Additional `Parameters` for the request. These will be JSON encoded.
    ///                     The default is `nil`.
    ///   - headers:        Additional `HTTPHeaders` for the request. The default is `nil`.
    ///   - sessionManager: The session manager responsible for the request.
    /// - Throws: Throws an error if the URL request could not be formed from the components,
    ///           including where the JSON encoding fails.
    public convenience init(url: URLConvertible,
                            method: HTTPMethod = .get,
                            parameters: Parameters? = nil,
                            headers: HTTPHeaders? = nil,
                            sessionManager: SessionManager = .default) throws {
        var request: URLRequestConvertible = try URLRequest(url: url, method: method, headers: headers)
        if let parameters = parameters {
            request = try JSONEncoding.default.encode(request, with: parameters)
        }
        self.init(urlRequest: request, sessionManager: sessionManager)
    }
    
    
    // MARK: - Request loading
    
    /// Overrides the loadRequest method to create the appropriate Alamofire `Request`.
    public final override func loadRequest() {
        super.request = sessionManager.request(urlRequest).responseJSON { [weak self] in self?.response = $0 }
    }
    
}
