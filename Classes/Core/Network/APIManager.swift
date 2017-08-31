//
//  APIManager.swift
//  MPOL
//
//  Created by Herli Halim on 11/5/17.
//
//

import Alamofire
import Unbox
import PromiseKit

/// MPOL APIManager stack for MPOL applications.
/// The APIManager doesn't assume anything in regards to model.
open class APIManager {

    open let configuration: APIManagerConfigurable

    private let baseURL: URL
    private let errorMapper: ErrorMapper?
    private let sessionManager: SessionManager

    private let plugins: [PluginType]

    open var authenticationPlugin: AuthenticationPlugin? = nil

    public init(configuration: APIManagerConfigurable) {
        self.configuration = configuration
        baseURL = try! configuration.url.asURL()
        errorMapper = configuration.errorMapper

        plugins = configuration.plugins ?? []

        sessionManager = SessionManager(configuration: configuration.urlSessionConfiguration,
                                        serverTrustPolicyManager: configuration.trustPolicyManager)
    }

    /// Perform specified network request.
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return of specified type.
    open func performRequest<T: Unboxable>(_ networkRequest: NetworkRequestType) throws -> Promise<T> {
        return dataRequestPromise(try urlRequest(from: networkRequest))
    }

    /// Perform specified network request.
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return array of specified type.
    open func performRequest<T: Unboxable>(_ networkRequest: NetworkRequestType) throws -> Promise<[T]> {
        return dataRequestPromise(try urlRequest(from: networkRequest))
    }

    /// Request for access token.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A promise for access token.
    open func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken> {

        let path = "login"
        let parameters = grant.parameters

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters, method: .post)

        return try! performRequest(networkRequest)

    }

    /// Search for entity using specified request.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameters:
    ///   - source: The data source of the entity to be searched.
    ///   - request: The request with the parameters to search the entity.
    /// - Returns: A promise to return search result of specified entity.
    open func searchEntity<SearchRequest: EntitySearchRequestable>(in source: EntitySource, with request: SearchRequest) -> Promise<SearchResult<SearchRequest.ResultClass>> {

        let path = "{source}/entity/{entityType}/search"
        var parameters = request.parameters
        parameters["source"] = source
        parameters["entityType"] = SearchRequest.ResultClass.serverTypeRepresentation

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)

        return try! performRequest(networkRequest)

    }
    
    /// Fetch entity details using specified request.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameters:
    ///   - source: The data source of entity to be fetched.
    ///   - request: The request with the parameters to fetch the entity.
    /// - Returns: A promise to return specified entity details.
    open func fetchEntityDetails<FetchRequest: EntityFetchRequestable>(in source: EntitySource, with request: FetchRequest) -> Promise<FetchRequest.ResultClass> {
        
        let path = "{source}/entity/{entityType}/{id}"
        
        var parameters = request.parameters
        parameters["source"] = source
        parameters["entityType"] = FetchRequest.ResultClass.serverTypeRepresentation

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        
        return try! performRequest(networkRequest)

    }

    // MARK : - Internal Utilities

    private func url(with path: String) -> URL {
        return baseURL.appendingPathComponent(path)
    }

    private var allPlugins: [PluginType] {
        guard let authenticationPlugin = authenticationPlugin else {
            return plugins
        }

        var new = plugins
        new.append(authenticationPlugin)

        return new
    }

    private func urlRequest(from networkRequest: NetworkRequestType) throws -> URLRequest {
        let path = networkRequest.path
        let requestPath = url(with: path)

        let parameters = networkRequest.parameters

        let request = try URLRequest(url: requestPath, method: networkRequest.method)
        let encodedURLRequest = try networkRequest.parameterEncoding.encode(request, with: parameters)

        return adaptedRequest(encodedURLRequest, using: allPlugins)
    }

    private func adaptedRequest(_ urlRequest: URLRequest, using plugins: [PluginType]) -> URLRequest {
        let adaptedRequest = self.plugins.reduce(urlRequest) { $1.adapt($0) }
        return adaptedRequest
    }

    private func request(_ urlRequest: URLRequest) -> DataRequest {
        let dataRequest = sessionManager.request(urlRequest)
        let progress = dataRequest.progress
        progress.cancellationHandler = {
            dataRequest.cancel()
        }
        progress.resumingHandler = {
            dataRequest.resume()
        }
        progress.pausingHandler = {
            dataRequest.suspend()
        }
        return dataRequest
    }

    // Handling single object
    private func dataRequestPromise<T: Unboxable>(_ urlRequest: URLRequest) -> Promise<T> {

        let dataRequest = request(urlRequest)

        let mapper = errorMapper
        return Promise { fulfill, reject in
            dataRequest.validate().responseObject(completionHandler: { (response: DataResponse<T>) in
                switch response.result {
                case .success(let result):
                    fulfill(result)
                case .failure(let error):
                    let wrappedError = APIManagerError(underlyingError: error, response: response.toDefaultDataResponse())
                    if let mapper = mapper {
                        reject(mapper.mappedError(from: wrappedError))
                    } else {
                        reject(wrappedError)
                    }
                }
            })
        }
    }

    // Handling array
    private func dataRequestPromise<T: Unboxable>(_ urlRequest: URLRequest) -> Promise<[T]> {

        let dataRequest = request(urlRequest)

        let mapper = errorMapper
        return Promise { fulfill, reject in
            dataRequest.validate().responseArray(completionHandler: { (response: DataResponse<[T]>) in
                switch response.result {
                case .success(let result):
                    fulfill(result)
                case .failure(let error):
                    let wrappedError = APIManagerError(underlyingError: error, response: response.toDefaultDataResponse())
                    if let mapper = mapper {
                        reject(mapper.mappedError(from: wrappedError))
                    } else {
                        reject(wrappedError)
                    }
                }
            })
        }
    }
}

public extension APIManager {

    private static var _sharedManager: APIManager?

    public static var shared: APIManager! {
        get {
            guard let manager = _sharedManager else {
                fatalError("`APIManager.shared` needs to be assigned before use.")
            }
            return manager
        }
        set {
            _sharedManager = newValue
        }
    }
}
