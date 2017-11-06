//
//  UnboxableAlamofireResponseSerializer.swift
//  MPOL
//
//  Created by Herli Halim on 11/5/17.
//
//

import Alamofire
import Unbox

extension Request {
    
    /// Creates a response serializer that returns an object that comforms to Unboxable from response/
    ///
    /// - Parameters:
    ///   - options: The JSON serialization reading options. Defaults to `.allowFragments`.
    ///   - keyPath: The keyPath as the beginning point.
    ///   - response: The response from the server.
    ///   - data: The data returned from the server.
    ///   - error: The error already encountered if it exists.
    /// - Returns: The result data type.
    public static func serializeResponseUnboxable<T: Unboxable>(keyPath: String?, options: JSONSerialization.ReadingOptions = .allowFragments, response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<T> {
        if let error = error {
            return .failure(error)
        }
        
        let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: options)
        let result = jsonResponseSerializer.serializeResponse(nil, response, data, error)
        
        guard let json = result.value as? UnboxableDictionary else {
            return .failure(UnboxError.invalidData)
        }
        
        do {
            if let keyPath = keyPath {
                return .success(try unbox(dictionary: json, atKeyPath: keyPath))
            } else {
                return .success(try unbox(dictionary: json))
            }
        } catch let error {
            return .failure(error)
        }
    }
    
    /// Creates a response serializer that returns an array of object that comforms to Unboxable from response.
    ///
    /// - Parameters:
    ///   - options: The JSON serialization reading options. Defaults to `.allowFragments`.
    ///   - keyPath: The keyPath as the beginning point.
    ///   - response: The response from the server.
    ///   - data: The data returned from the server.
    ///   - error: The error already encountered if it exists.
    /// - Returns: The result data type.
    public static func serializeResponseUnboxableArray<T: Unboxable>(keyPath: String?, options: JSONSerialization.ReadingOptions = .allowFragments, response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<[T]> {
        if let error = error {
            return .failure(error)
        }
        
        let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: options)
        let result = jsonResponseSerializer.serializeResponse(nil, response, data, error)
        
        do {
            if let json = result.value as? UnboxableDictionary, let keyPath = keyPath {
                return .success(try unbox(dictionary: json, atKeyPath: keyPath))
            } else if let json = result.value as? [UnboxableDictionary] {
                return .success(try unbox(dictionaries: json))
            } else {
                return .failure(UnboxError.invalidData)
            }
        } catch let error {
            return .failure(error)
        }
    }

}

extension DataRequest {
    
    /// Creates a response serializer that returns an object that conforms to Unboxable result type constructed from the response data
    ///
    /// - Parameters:
    ///   - keyPath: The keyPath as the beginning point.
    ///   - options: The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - Returns: a Unboxable object response serializer.
    public static func unboxableResponseSerializer<T: Unboxable>(keyPath: String?, options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            return Request.serializeResponseUnboxable(keyPath: keyPath, options: options, response: response, data: data, error: error)
        }
    }
    
    /// Creates a response serializer that returns an array of object that conforms to Unboxable result type constructed from the response data
    ///
    /// - Parameters:
    ///   - keyPath: The keyPath as the beginning point.
    ///   - options: The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - Returns: a Unboxable object response serializer.
    public static func unboxableArrayResponseSerializer<T: Unboxable>(keyPath: String?, options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer { _, response, data, error in
            return Request.serializeResponseUnboxableArray(keyPath: keyPath, options: options, response: response, data: data, error: error)
        }
    }
    
    
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - keyPath: The keyPath as the beginning point.
    ///   - options: The JSON serialization reading options. Defaults to `.allowFragments`.
    ///   - completionHandler: A closure to be executed once the request has finished and the data has been mapped .
    /// - Returns: The request
    @discardableResult
    public func responseObject<T: Unboxable>(queue: DispatchQueue? = nil, keyPath: String? = nil, options: JSONSerialization.ReadingOptions = .allowFragments, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.unboxableResponseSerializer(keyPath: keyPath, options: options), completionHandler: completionHandler)
    }
    
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - keyPath: The keyPath as the beginning point.
    ///   - options: The JSON serialization reading options. Defaults to `.allowFragments`.
    ///   - completionHandler: A closure to be executed once the request has finished and the data has been mapped .
    /// - Returns: The request
    @discardableResult
    public func responseArray<T: Unboxable>(queue: DispatchQueue? = nil, keyPath: String? = nil, options: JSONSerialization.ReadingOptions = .allowFragments, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.unboxableArrayResponseSerializer(keyPath: keyPath, options: options), completionHandler: completionHandler)
    }
    
}
