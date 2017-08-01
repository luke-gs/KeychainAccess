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


/// MPOL APIManager stack for MPOL applications.
/// The APIManager doesn't assume anything in regards to source and model.
/// Application will need to provide concrete types.
///
/// One way of using this is to create a subclass passing in some of the configuration to
/// erase the generic requirements.
///
/// struct MyAPIURLRequestConfiguration: APIURLRequestProviderConfigurable {
///    typealias Source = MySource
///    public let url: URLConvertible
///
///    public init(url: URLConvertible) {
///        self.url = url
///    }
/// }
///
/// class MyAPIManager: APIManager<MyAPIURLRequestConfiguration> {
///
///    typealias Source = MyAPIURLRequestConfiguration.Source
///
///    override init(configuration: MyAPIURLRequestConfiguration) {
///        super.init(configuration: configuration)
///    }
///
///    func searchPerson(`in` source: MySource, with surname: String) -> Promise<SearchResult<Person>> {
///        // Call the `searchEntity(in:with)` internally with the correct parameters.
///    }
/// }

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
    
    /// Request for access token.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A promise for access token.
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
    
    
    /// Search for entity using specified request.
    ///
    /// - Parameters:
    ///   - source: The data source of the entity to be searched.
    ///   - request: The request with the parameters to search the entity.
    /// - Returns: A promise to return search result of specified entity.
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
    
    
    /// Fetch entity details using specified request.
    ///
    /// - Parameters:
    ///   - source: The data source of entity to be fetched.
    ///   - request: The request with the parameters to fetch the entity.
    /// - Returns: A promise to return specified entity details.
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
    private func url(with path: String) -> URL {
        return baseURL.appendingPathComponent(path)
    }
}
