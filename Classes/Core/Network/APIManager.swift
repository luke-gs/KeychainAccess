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

    private var plugins: [Plugin] = []
    public private(set) var authenticationPlugin: AuthenticationPlugin? = nil
    public private(set) var authenticationPluginFilterRule: PluginFilterRule = .allowAll

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

        let path = grant.path
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

        return try! self.performRequest(networkRequest)
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

        return try! self.performRequest(networkRequest)
    }

    /// Performs a request for the `urlRequest` and returns a `Promise` with processed `DataResponse`.
    open func dataRequest(_ urlRequest: Promise<URLRequest>) -> Promise<DataResponse<Data>> {
        return createSessionRequestWithProgress(from: urlRequest).then { (dataRequest) in

            // Notify plugins of request
            let allPlugins = self.applicablePlugins(for: dataRequest.request?.url)
            allPlugins.forEach {
                $0.willSend(dataRequest)
            }

            // Perform request
            return dataRequest.validate().responseDataPromise()
                .then { (response) in
                    allPlugins.forEach({
                        $0.didReceiveResponse(response)
                    })

                    var processed = Promise(value: response)
                    for plugin in allPlugins {
                        processed = processed.then { return plugin.processResponse($0) }
                    }
                    return processed
            }
        }
    }

    public func setAuthenticationPlugin(_ plugin: AuthenticationPlugin, rule: PluginFilterRule = .allowAll) {
        authenticationPlugin = plugin
        authenticationPluginFilterRule = rule
    }

    // MARK : - Internal Utilities

    private var allPlugins: [Plugin] {

        var allPlugins = plugins

        if let authenticationPlugin = authenticationPlugin {
            allPlugins.append(authenticationPlugin.withRule(authenticationPluginFilterRule))
        }

        return allPlugins
    }

    private func applicablePlugins(for url: URL?) -> [PluginType] {

        guard let url = url else {
            // No URL specified, allow all.
            return allPlugins.map { $0.plugin }
        }

        return allPlugins.flatMap {
            return $0.isApplicable(to: url) ? $0.plugin : nil
        }
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

        return adaptedRequest(encodedURLRequest, using: applicablePlugins(for: requestPath))
    }
    
    private func adaptedRequest(_ urlRequest: URLRequest, using plugins: [PluginType]) -> Promise<URLRequest> {
        let initial = Promise(value: urlRequest)
        return applicablePlugins(for: urlRequest.url).reduce(initial) { (promise, plugin) in
            return promise.then { return plugin.adapt($0) }
        }
    }
    
    private func createSessionRequestWithProgress(from urlRequest: Promise<URLRequest>) -> Promise<DataRequest> {
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

    /// Returns a `Promise` that executes the entire chain of related promises for the network request (including serializing response).
    private func requestPromise<T: ResponseSerializing>(_ urlRequest: Promise<URLRequest>, using serializer: T) -> Promise<T.ResultType> {

        let mapper = self.errorMapper
        return Promise { fulfill, reject in
            dataRequest(urlRequest).then { (processedResponse) -> Void in
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
            }.catch(policy: .allErrors) { error in
                // It's used to be the `processedResponse(_:)` used to be APIManager's internal state.
                // and it'll never throw error due to being wrapped inside `Alamofire.Result(T)`.
                // However, it's now exposed externally and it's possible that something external is rejecting the promise.
                reject(error)
            }
        }
    }
}

// MARK: - Shared manager configuration
/// Allows setting a global sharedManager for convenience.
extension APIManager {

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

/// Name-spaced default implementation of `ResponseSerializing`.
/// `JSONObjectResponseSerializer` and `JSONObjectResponseSerializer`, for example,
/// are very generic name.
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

    fileprivate struct DataResponseSerializer: ResponseSerializing {
        public typealias ResultType = Data

        public init() {

        }

        public func serializedResponse(from dataResponse: DataResponse<Data>) -> Alamofire.Result<ResultType> {
            return DataRequest.serializeResponseData(response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
        }
    }

    // JSON serialization of single object
    public struct JSONObjectResponseSerializer: ResponseSerializing {
        public typealias ResultType = [String:Any]
        public init() {}

        public func serializedResponse(from dataResponse: DataResponse<Data>) -> Alamofire.Result<ResultType> {
            let result = DataRequest.serializeResponseJSON(options: .allowFragments, response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
            switch result {
            case .success(let json):
                if let json = json as? ResultType {
                    return .success(json)
                } else {
                    return .failure(ParsingError.incorrectFormat)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    // Serialization of for arrays of dictionaries
    public struct JSONObjectArrayResponseSerializer: ResponseSerializing {
        public typealias ResultType = [[String:Any]]

        public init() {

        }

        public func serializedResponse(from dataResponse: DataResponse<Data>) -> Alamofire.Result<ResultType> {
            let result = DataRequest.serializeResponseJSON(options: .allowFragments, response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
            switch result {
            case .success(let json):
                if let json = json as? ResultType {
                    return .success(json)
                } else {
                    return .failure(ParsingError.incorrectFormat)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
}

extension DataRequest {
    
    fileprivate func responseDataPromise() -> Promise<DataResponse<Data>> {
        return Promise { (fulfill, _) in
            self.responseData { fulfill($0) }
        }
    }
}
