//
//  APIManager.swift
//  MPOL
//
//  Created by Herli Halim on 11/5/17.
//
//

import MPOLKit
import Alamofire
import Unbox
import PromiseKit

open class APIManager<Configuration: APIURLRequestProviderConfigurable> {
    
    open let sessionManager: SessionManager
    
    open let baseURL: URL
    
    private let urlQueryBuilder = URLQueryBuilder()
    
    let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.baseURL = try! configuration.url.asURL()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        sessionManager = SessionManager(configuration: configuration)
    }
    
    open func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken> {
        let path = "login"
        let requestPath = url(with: path)
        
        let parameters = grant.parameters
        
        // Only known parameters are passed in, if this fail, might as well crash.
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: parameters)
        
        let dataRequest = sessionManager.request(encodedURLRequest)
        return Promise { [weak self] fulfill, reject in
            dataRequest.responseObject(completionHandler: { (response: DataResponse<OAuthAccessToken>) in
                switch response.result {
                case .success(let token):
                    let adapter = AuthenticationHeaderAdapter(authenticationMode: .accessTokenAuthentication(token: token))
                    self?.sessionManager.adapter = adapter
                    fulfill(token)
                case .failure(let error):
                    reject(error)
                }
            })
        }
    }
    
    open func searchEntity<SearchRequest: EntitySearchRequestable>(`in` source: Configuration.Source, with request: SearchRequest) -> Promise<SearchResult<SearchRequest.ResultClass>> {
        
        let path = "{source}/entity/{entityType}/search"
        
        var parameters = request.parameters
        parameters["source"] = source
        parameters["entityType"] = SearchRequest.ResultClass.serverTypeRepresentation
        
        let result = try! urlQueryBuilder.urlPathWith(template: path, parameters: parameters)
        
        let requestPath = url(with: result.path)
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: result.parameters)
        
        let dataRequest = sessionManager.request(encodedURLRequest)
        
        return Promise { fulfill, reject in
            dataRequest.responseObject(completionHandler: { (response: DataResponse<SearchResult<SearchRequest.ResultClass>>) in
                switch response.result {
                case .success(let result):
                    fulfill(result)
                case .failure(let error):
                    reject(error)
                }
            })
        }
    }
    
    open func fetchEntityDetails<FetchRequest: EntityFetchRequestable>(`in` source: Configuration.Source, with request: FetchRequest) -> Promise<FetchRequest.ResultClass> {
        
        let path = "{source}/entity/{entityType}/{id}"
        
        var parameters = request.parameters
        parameters["source"] = source
        parameters["entityType"] = FetchRequest.ResultClass.serverTypeRepresentation
        
        let result = try! urlQueryBuilder.urlPathWith(template: path, parameters: parameters)
        
        let requestPath = url(with: result.path)
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: result.parameters)
        
        let dataRequest = sessionManager.request(encodedURLRequest)
        
        return Promise { fulfill, reject in
            dataRequest.responseObject(completionHandler: { (response: DataResponse<FetchRequest.ResultClass>) in
                switch response.result {
                case .success(let result):
                    fulfill(result)
                case .failure(let error):
                    reject(error)
                }
            })
        }
    }

    // MARK : - Internal Utilities
    func url(with path: String) -> URL {
        return baseURL.appendingPathComponent(path)
    }
}
