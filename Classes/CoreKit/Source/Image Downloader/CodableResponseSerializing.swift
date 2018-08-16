//
//  CodableResponseSerializing.swift
//  MPOLKit
//
//  Created by QHMW64 on 22/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Alamofire

public class CodableResponseSerializing<T: Codable>: ResponseSerializing {

    public typealias ResultType = T
    public let keyPath: String?
    public let decoder: JSONDecoder?
    public init(keyPath: String? = nil, decoder: JSONDecoder? = nil) {
        self.keyPath = keyPath
        self.decoder = decoder
    }

    public func serializedResponse(from dataResponse: DataResponse<Data>) -> Result<ResultType> {
        return DataRequest.serializeResponseCodable(keyPath: keyPath, response: dataResponse.response, data: dataResponse.data, error: dataResponse.error, decoder: decoder)
    }
}

extension Request {

    /// Creates a response serializer that returns an object that comforms to Codable from response/
    ///
    /// - Parameters:
    ///   - options: The JSON serialization reading options. Defaults to `.allowFragments`.
    ///   - keyPath: The keyPath as the beginning point.
    ///   - response: The response from the server.
    ///   - data: The data returned from the server.
    ///   - error: The error already encountered if it exists.
    /// - Returns: The result data type.
    public static func serializeResponseCodable<T: Codable>(keyPath: String?, options: JSONSerialization.ReadingOptions = .allowFragments, response: HTTPURLResponse?, data: Data?, error: Error?, decoder: JSONDecoder?) -> Result<T> {
        
        if let error = error {
            return .failure(error)
        }
        guard let data = data else {
            return .failure(ResourceError.invalidResourceData)
        }

        // Use a default JSON Decoder if one was not provided
        var decoder: JSONDecoder! = decoder
        if decoder == nil {
            decoder = JSONDecoder()
            decoder.dateDecodingStrategy = ISO8601DateTransformer.jsonDateDecodingStrategy()
        }
        
        do {
            return .success(try decoder.decode(T.self, from: data))
        } catch let error {
            return .failure(error)
        }

    }
}


