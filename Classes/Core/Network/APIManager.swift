//
//  APIManager.swift
//  MPOL
//
//  Created by Herli Halim on 11/5/17.
//
//

import Alamofire
import Unbox

open class APIManager<Provider: WebAPIURLRequestProvider> {
    
    public typealias Configuration = Provider.Configuration
    
    open var baseURL: URL {
        get {
            return urlProvider.baseURL
        }
    }
    
    open let sessionManager: SessionManager
    
    open let urlProvider: Provider
    
    public init(urlProvider: Provider) {
        self.urlProvider = urlProvider
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        sessionManager = SessionManager(configuration: configuration)
    }
    
    // MARK: - Authentications
    
    open func accessTokenRequestOperation(for grant: OAuthAuthorizationGrant, completion: ((DataResponse<OAuthAccessToken>) -> Void)? = nil) -> UnboxingGroupOperation<OAuthAccessToken> {
        
        let request = urlProvider.accessTokenRequest(for: grant)
        
        let group = unboxOperation(with: request) { [weak self] (response: DataResponse<OAuthAccessToken>) in
            switch response.result {
            case .success(let token):
                let adapter = AuthenticationHeaderAdapter(authenticationMode: .accessTokenAuthentication(token: token))
                self?.sessionManager.adapter = adapter
            case .failure: break
            }
            
            completion?(response)
        }
        
        return group
    }
    
    // MARK: Persons
    
    open func searchPersonOperation<P: Person>(from source: Configuration.Source, with parameters: Configuration.PersonSearchParametersType, completion: ((DataResponse<[P]>) -> Void)? = nil) -> UnboxingArrayGroupOperation<P> {
        
        let request = urlProvider.searchPerson(from: source, with: parameters)
        return unboxArrayOperation(with: request, completion: completion)
    }
    
    open func fetchPersonDetailsOperation<P: Person>(from source: Configuration.Source, with id: String, completion: ((DataResponse<P>) -> Void)? = nil) -> UnboxingGroupOperation<P> {
        
        let request = urlProvider.fetchPersonDetails(from: source, with: id)
        return unboxOperation(with: request, completion: completion)
    }
    
    // MARK: Vehicles
    
    open func searchVehicleOperation<V: Vehicle>(from source: Configuration.Source, with parameters: Configuration.VehicleSearchParametersType, completion: ((DataResponse<[V]>) -> Void)? = nil) -> UnboxingArrayGroupOperation<V> {
        
        let request = urlProvider.searchVehicle(from: source, with: parameters)
        return unboxArrayOperation(with: request, completion: completion)
    }
    
    open func fetchVehicleDetailsOperation<V: Vehicle>(from source: Configuration.Source, with id: String, completion: ((DataResponse<V>) -> Void)? = nil) -> UnboxingGroupOperation<V> {
        
        let request = urlProvider.fetchVehicleDetails(from: source, with: id)
        return unboxOperation(with: request, completion: completion)
    }

    
    // MARK : - Internal Utilities
    
    private func unboxOperation<T: Unboxable>(with urlRequest: URLRequest, completion: ((DataResponse<T>) -> Void)?) -> UnboxingGroupOperation<T> {
        let provider = URLJSONRequestOperation(urlRequest: urlRequest, sessionManager: sessionManager)
        let unboxer = UnboxingOperation<T>(provider: provider)
        
        let group = UnboxingGroupOperation(provider: provider, unboxer: unboxer) { (response: DataResponse<T>) in
            completion?(response)
        }
        
        return group
    }
    
    private func unboxArrayOperation<T: Unboxable>(with urlRequest: URLRequest, completion: ((DataResponse<[T]>) -> Void)?) -> UnboxingArrayGroupOperation<T> {
        let provider = URLJSONRequestOperation(urlRequest: urlRequest, sessionManager: sessionManager)
        let unboxer = UnboxingArrayOperation<T>(provider: provider)
        
        let group = UnboxingArrayGroupOperation(provider: provider, unboxer: unboxer) { (response: DataResponse<[T]>) in
            completion?(response)
        }
        
        return group
    }
}
