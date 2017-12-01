//
//  CodableResponseSerializing.swift
//  MPOLKit
//
//  Created by QHMW64 on 22/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Alamofire

class CodableResponseSerializing<T: Codable>: ResponseSerializing {
    public typealias ResultType = T
    public let keyPath: String?
    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    public func serializedResponse(from dataResponse: DataResponse<Data>) -> Result<ResultType> {
        return DataRequest.serializeResponseCodable(keyPath: keyPath, response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
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
    public static func serializeResponseCodable<T: Codable>(keyPath: String?, options: JSONSerialization.ReadingOptions = .allowFragments, response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<T> {
        if let error = error {
            return .failure(error)
        }
        guard let data = data else {
            return
        }
        let decoder = JSONDecoder()
        do {
            return .success(try decoder.decode(T.self, from: data))
        } catch let error {
            return .failure(error)
        }

    }
}


