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
        let request = try urlRequest(from: networkRequest)
        return dataRequestPromise(request)
    }

    /// Perform specified network request.
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return array of specified type.
    open func performRequest<T: Unboxable>(_ networkRequest: NetworkRequestType) throws -> Promise<[T]> {
        let request = try urlRequest(from: networkRequest)
        return dataRequestPromise(request)
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
        parameters["source"] = source.serverSourceName
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
        parameters["source"] = source.serverSourceName
        parameters["entityType"] = FetchRequest.ResultClass.serverTypeRepresentation

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        
        return try! performRequest(networkRequest)

    }
    
    /// Fetch manifest data
    ///
    /// - Parameters:
    ///   - date: The date last successful fetch, to only return items changes since this date. If no date, and entire snapshot of the manifest data will be requested.
    ///
    /// - Returns: A promis to return the manifest data
    open func fetchManifest(for date: Date?) -> Promise<[[String : Any]]> {
        var path = "manifest/app"
        var parameters:[String: String] = [:]
        
        if let date = date{
            let interval = Int(date.timeIntervalSince1970)
            path.append("/{interval}")
            parameters["interval"] = String(interval)
        }
        
        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        
        let newRequest = try! urlRequest(from: networkRequest)
        let dataRequest = request(newRequest)
        let allPlugins = self.allPlugins
        allPlugins.forEach {
            $0.willSend(dataRequest)
        }
        
        let mapper = errorMapper
        return Promise { fulfill, reject in
            dataRequest.validate().response(completionHandler: { (response: DefaultDataResponse) in
                allPlugins.forEach {
                    $0.willSend(dataRequest)
                }
                
                do {
                    if let responseData = response.data{
                        
                        let responseArray = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
                        if let manifestArray = responseArray as? [[String : Any]] {
                            fulfill(manifestArray)
                        } else {
                            fulfill([])
                        }
                    } else {
                        if let error = response.error {
                            let wrappedError = APIManagerError(underlyingError: error, response: response)
                            if let mapper = mapper {
                                reject(mapper.mappedError(from: wrappedError))
                            } else {
                                reject(wrappedError)
                            }
                        }
                    }
                } catch let parseError {
                    reject (parseError)
                }
            })
        }
    }

    // MARK : - Internal Utilities

    private func url(with path: String) -> URL {
        return baseURL.appendingPathComponent(path)
    }

    private var allPlugins: [PluginType] {
        var allPlugins = plugins
        if let authenticationPlugin = authenticationPlugin {
            allPlugins.append(authenticationPlugin)
            allPlugins.append(GeolocationPlugin()) // Only add if user is authenticated. i.e: Logged in
        }
        
        return allPlugins
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
        let adaptedRequest = allPlugins.reduce(urlRequest) { $1.adapt($0) }
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
        let allPlugins = self.allPlugins
        allPlugins.forEach {
            $0.willSend(dataRequest)
        }

        let mapper = errorMapper
        return Promise { fulfill, reject in

            dataRequest.validate().responseData(completionHandler: { response in

                allPlugins.forEach({
                    $0.didReceiveResponse(response)
                })

                let processedResponse = allPlugins.reduce(response) { $1.processResponse($0) }
                let result: Alamofire.Result<T> = DataRequest.serializeResponseUnboxable(keyPath: nil, response: processedResponse.response, data: processedResponse.data, error: processedResponse.error)

                switch result {
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
        let allPlugins = self.allPlugins
        allPlugins.forEach {
            $0.willSend(dataRequest)
        }

        let mapper = errorMapper

        return Promise { fulfill, reject in

            dataRequest.validate().responseData(completionHandler: { response in

                allPlugins.forEach({
                    $0.didReceiveResponse(response)
                })

                let processedResponse = allPlugins.reduce(response) { $1.processResponse($0) }
                let result: Alamofire.Result<[T]> = DataRequest.serializeResponseUnboxableArray(keyPath: nil, response: processedResponse.response, data: processedResponse.data, error: processedResponse.error)

                switch result {
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
