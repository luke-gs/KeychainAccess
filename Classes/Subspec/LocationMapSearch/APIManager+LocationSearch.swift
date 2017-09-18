//
//  APIManager+LocationRadiusSearch.swift
//  Pods
//
//  Created by RUI WANG on 5/9/17.
//
//

import PromiseKit
import Alamofire

extension APIManager {
    
    /// Search locations within a radius
    ///
    /// - Parameters:
    ///   - source: The data source of search location
    ///   - request: The request with search parameters
    /// - Returns: A promise to return search result with specific entity type
    open func locationRadiusSearch<T: EntitySearchRequestable> (in source: EntitySource, with request: T) -> Promise<SearchResult<T.ResultClass>> {
        
        let path = "{source}/entity/location/search/radius"
        var parameters = request.parameters
        parameters["source"] = source
        
        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        
        return try! performRequest(networkRequest)
        
    }
    
    /// Search locations within a bounding box
    ///
    /// - Parameters:
    ///   - source: The data source of search location
    ///   - request: The request with search parameters
    /// - Returns: A promise to return search result with specific entity type
    open func locationBoundingBoxSearch<T: EntitySearchRequestable> (in source: EntitySource, with request: T) -> Promise<SearchResult<T.ResultClass>> {
        let path = "{source}/entity/location/search/boundingbox?"
        var parameters = request.parameters
        parameters["source"] = source
        
        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        
        return try! performRequest(networkRequest)
    }
    
    
}
