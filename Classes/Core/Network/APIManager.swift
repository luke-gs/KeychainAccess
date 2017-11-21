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

    /// Perform specified network request that returns the data and the raw response
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return of specified type.
    open func performRequest(_ networkRequest: NetworkRequestType) throws -> Promise<(Data, HTTPURLResponse?)> {
        let request = try urlRequest(from: networkRequest)
        return requestPromise(request, using: DataHTTPURLResponsePairResponseSerializer())
    }

    /// Perform specified network request that uses `ResponseSerializing` to map the result.
    ///
    /// - Parameters:
    ///   - networkRequest: The network request to be executed.
    ///   - serializer: `ResponseSerializing` conformer.
    /// - Returns: A promise to return result type from `ResponseSerializing`.
    open func performRequest<T: ResponseSerializing>(_ networkRequest: NetworkRequestType, using serializer: T) throws -> Promise<T.ResultType> {
        let request = try urlRequest(from: networkRequest)
        return requestPromise(request, using: serializer)
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

        if requiresLocation {
            return LocationManager.shared.requestLocation().recover { error -> CLLocation in
                return LocationManager.shared.lastLocation ?? CLLocation() // Had to keep this in to avoid making the requestLocation optional
                }.then { _ -> Promise<SearchResult<SearchRequest.ResultClass>> in
                    let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
                    
                    return try! self.performRequest(networkRequest)
            }
        } else {
            let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
            
            return try! self.performRequest(networkRequest)
        }
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
        
        if requiresLocation {
            return LocationManager.shared.requestLocation().recover { error -> CLLocation in
                return LocationManager.shared.lastLocation ?? CLLocation() // Had to keep this in to avoid making the requestLocation optional
                }.then { _ -> Promise<FetchRequest.ResultClass> in
                    let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
                    
                    return try! self.performRequest(networkRequest)
            }
        } else {
            let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
            
            return try! self.performRequest(networkRequest)
        }
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
        
        return processDataRequest(from: newRequest).then { (request) in
            let allPlugins = self.allPlugins
            allPlugins.forEach {
                $0.willSend(request)
            }
            
            let mapper = self.errorMapper
            return Promise { fulfill, reject in
                
                request.validate().responseData(completionHandler: { response in
                    
                    allPlugins.forEach({
                        $0.didReceiveResponse(response)
                    })
                    
                    switch response.result {
                    case .success(_):
                        do {
                            if let responseData = response.data{
                                
                                let responseArray = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
                                if let manifestArray = responseArray as? [[String : Any]] {
                                    fulfill(manifestArray)
                                } else {
                                    reject(ManifestError("Manifest response not in desired format"))
                                }
                            }
                        } catch let parseError {
                            reject (parseError)
                        }
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
    
    // MARK : - Internal Utilities
    
    private var allPlugins: [PluginType] {
        var allPlugins = plugins
        if let authenticationPlugin = authenticationPlugin {
            allPlugins.append(authenticationPlugin)
        }
        
        return allPlugins
    }
    
    private var requiresLocation: Bool {
        return allPlugins.contains(where: { $0 is GeolocationPlugin })
    }
    
    private func urlRequest(from networkRequest: NetworkRequestType) throws -> Promise<URLRequest> {
        let path = networkRequest.path

        let requestPath: URL
        if networkRequest.isRelativePath {
            requestPath = baseURL.appendingPathComponent(path)
        } else {
            guard let urlPath = URL(string: path) else {
                throw AFError.invalidURL(url: path)
            }
            requestPath = urlPath
        }

        let parameters = networkRequest.parameters

        let request = try URLRequest(url: requestPath, method: networkRequest.method)
        let encodedURLRequest = try networkRequest.parameterEncoding.encode(request, with: parameters)

        return adaptedRequest(encodedURLRequest, using: allPlugins)
    }
    
    private func adaptedRequest(_ urlRequest: URLRequest, using plugins: [PluginType]) -> Promise<URLRequest> {
        let initial = Promise(value: urlRequest)
        return plugins.reduce(initial) { (promise, plugin) in
            return promise.then { return plugin.adapt($0) }
        }
    }
    
    private func processDataRequest(from urlRequest: Promise<URLRequest>) -> Promise<DataRequest> {
        return urlRequest.then { [unowned self] request in
            let dataRequest = self.sessionManager.request(request)
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
            return Promise(value: dataRequest)
        }
    }
    
    /// Performs a request for the `urlRequest` and returns a `Promise` with processed `DataResponse`.
    private func dataRequest(_ urlRequest: Promise<URLRequest>) -> Promise<DataResponse<Data>> {
        return processDataRequest(from: urlRequest).then { (request) in
            
            // Notify plugins of request
            let allPlugins = self.allPlugins
            allPlugins.forEach {
                $0.willSend(request)
            }
            
            // Perform request
            return Promise { fulfill, _ in
                request.validate().responseData(completionHandler: { response in
                    
                    allPlugins.forEach({
                        $0.didReceiveResponse(response)
                    })
                    
                    var promise = Promise(value: response)
                    for plugin in allPlugins {
                        promise = promise.then { return plugin.processResponse($0) }
                    }
                    _ = promise.then { response in
                        fulfill(response)
                    }
                })
            }
        }
    }

    /// Returns a `Promise` that executes the entire chain of related promises for the network request (including serializing response).
    private func requestPromise<T: ResponseSerializing>(_ urlRequest: Promise<URLRequest>, using serializer: T) -> Promise<T.ResultType> {

        let mapper = self.errorMapper
        return Promise { fulfill, reject in
            _ = dataRequest(urlRequest).then { (processedResponse) -> Void in
                let result = serializer.serializedResponse(from: processedResponse)

                switch result {
                case .success(let result):
                    fulfill(result)
                case .failure(let error):
                    let wrappedError = APIManagerError(underlyingError: error, response: processedResponse.toDefaultDataResponse())
                    if let mapper = mapper {
                        reject(mapper.mappedError(from: wrappedError))
                    } else {
                        reject(wrappedError)
                    }
                }
            }
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

// MARK: - ResponseSerializing

// Name-spaced default implementation `ResponseSerializing` that handles data.
extension APIManager {

    fileprivate struct DataHTTPURLResponsePairResponseSerializer: ResponseSerializing {
        typealias ResultType = (Data, HTTPURLResponse?)

        init() {

        }

        func serializedResponse(from dataResponse: DataResponse<Data>) -> Alamofire.Result<ResultType> {
            let result = DataRequest.serializeResponseData(response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
            let newResult: Alamofire.Result<ResultType>

            switch result {
            case .success(let value):
                newResult = .success((value, dataResponse.response))
            case .failure(let error):
                newResult = .failure(error)
            }

            return newResult
        }
    }

    public struct DataResponseSerializer: ResponseSerializing {
        public typealias ResultType = Data

        public init() {

        }

        public func serializedResponse(from dataResponse: DataResponse<Data>) -> Alamofire.Result<ResultType> {
            return DataRequest.serializeResponseData(response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
        }
    }
}
