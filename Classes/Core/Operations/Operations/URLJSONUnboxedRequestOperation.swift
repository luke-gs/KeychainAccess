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
final public class URLJSONUnboxedRequestOperation<UnboxableType: Unboxable>: URLRequestOperation {
    
    // MARK: - Properties
    
    public let sessionManager: SessionManager
    
    public override var request: Request? {
        get { return super.request }
        set {  }
    }
    
    public private(set) var urlRequest: URLRequestConvertible
    
    public private(set) var response: DataResponse<UnboxableType>?
    
    public let completionHandler: ((DataResponse<UnboxableType>) -> Void)?
    
    // MARK: - Initializers
    
    public init(urlRequest: URLRequestConvertible,
                sessionManager: SessionManager = .default,
                completionHandler: ((DataResponse<UnboxableType>) -> Void)? = nil) {
        self.urlRequest     = urlRequest
        self.sessionManager = sessionManager
        self.completionHandler = completionHandler
        super.init()
    }
    
    public convenience init(url: URLConvertible,
                            method: HTTPMethod = .get,
                            parameters: Parameters? = nil,
                            headers: HTTPHeaders? = nil,
                            sessionManager: SessionManager = .default,
                            completionHandler: ((DataResponse<UnboxableType>) -> Void)? = nil) throws {
        var request: URLRequestConvertible = try URLRequest(url: url, method: method, headers: headers)
        if let parameters = parameters {
            request = try JSONEncoding.default.encode(request, with: parameters)
        }
        self.init(urlRequest: request, sessionManager: sessionManager, completionHandler: completionHandler)
    }
    
    // MARK: - Request loading
    
    public final override func loadRequest() {
        super.request = sessionManager.request(urlRequest).validate().responseObject(completionHandler: { [weak self] (response: DataResponse<UnboxableType>) in
            self?.response = response
            self?.completionHandler?(response)
        })
    }
}
