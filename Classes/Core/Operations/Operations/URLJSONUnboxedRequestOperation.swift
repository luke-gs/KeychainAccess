//
//  URLJSONUnboxedRequestOperation.swift
//  MPOL
//
//  Created by Herli Halim on 15/5/17.
//
//

import Alamofire
import Unbox

/// A `URLRequestOperation` for conducting json requests with a remote server and parsing them to Unbox comformant.
///
/// `URLJSONUnboxedRequestOperation` lazily loads its request during execution from
/// the specified session manager.
public class URLJSONUnboxedRequestOperation<UnboxableType: Unboxable>: URLRequestOperation {
    
    // MARK: - Properties
    
    open private(set) var urlRequest: URLRequestConvertible
    
    open let sessionManager: SessionManager
    
    open override var request: Request? {
        get { return super.request }
        set {  }
    }
    
    open private(set) var response: DataResponse<UnboxableType>?
    
    public let type: UnboxableType.Type
    
    // MARK: - Initializers
    
    public init(urlRequest: URLRequestConvertible, type: UnboxableType.Type, sessionManager: SessionManager = .default) {
        self.urlRequest     = urlRequest
        self.sessionManager = sessionManager
        self.type = type
        super.init()
    }
    
    public convenience init(url: URLConvertible,
                            method: HTTPMethod = .get,
                            parameters: Parameters? = nil,
                            headers: HTTPHeaders? = nil,
                            type: UnboxableType.Type,
                            sessionManager: SessionManager = .default) throws {
        var request: URLRequestConvertible = try URLRequest(url: url, method: method, headers: headers)
        if let parameters = parameters {
            request = try JSONEncoding.default.encode(request, with: parameters)
        }
        self.init(urlRequest: request, type: type, sessionManager: sessionManager)
    }
    
    // MARK: - Request loading
    
    public final override func loadRequest() {
        super.request = sessionManager.request(urlRequest).validate().responseObject(completionHandler: { [weak self] in
            self?.response = $0
        })
    }
}
