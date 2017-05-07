//
//  URLJSONRequestOperation.swift
//  Pods
//
//  Created by Rod Brown on 7/5/17.
//
//

import Foundation
import Alamofire


open class URLJSONRequestOperation: URLRequestOperation {
    
    open var urlRequest: URLRequestConvertible
    
    open private(set) var response: DataResponse<Any>?
    
    public init(urlRequest: URLRequestConvertible) {
        self.urlRequest = urlRequest
        super.init()
    }
    
    public convenience init(url: URLConvertible,
                            method: HTTPMethod = .get,
                            parameters: Parameters? = nil,
                            headers: HTTPHeaders? = nil) throws {
        var request: URLRequestConvertible = try URLRequest(url: url, method: method, headers: headers)
        if let parameters = parameters {
            request = try JSONEncoding.default.encode(request, with: parameters)
        }
        self.init(urlRequest: request)
    }
    
    open override func loadRequest() {
        request = SessionManager.default.request(urlRequest).responseJSON { [weak self] in self?.response = $0 }
    }
    
}
