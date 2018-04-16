//
//  CodableRequest.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a request object that is encodable and Parameterisable, where a default
/// implementation of Parameterisable is provided that uses Codable to do the encoding.
///
/// Note: It would be nice if we could:
/// - Extend Codable to conform to Parameterisable automatically
/// - Convert directly from Codable to Dictionary
///
/// ... but currently not possible with Swift 4
///
public protocol CodableRequest: Encodable, Parameterisable {

    /// Request URL as relative path
    var relativePath: String { get }

    /// The encoder to use for converting object to parameters. Default is JSONEncoder with no configuration.
    var parametersEncoder: JSONEncoder { get }

    /// Whether to ignore conversion errors. Default is false.
    var ignoreConversionError: Bool { get }
}

/// Default implementation
extension CodableRequest {

    public var parametersEncoder: JSONEncoder {
        return JSONEncoder()
    }

    public var ignoreConversionError: Bool {
        return false
    }

    public var parameters: [String : Any] {
        /// There is no clean way to encode from Codable to dictionary, so we need to go via JSON :(
        if let data = try? parametersEncoder.encode(self) {
            if let parameters = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
                return parameters
            }
        }
        if ignoreConversionError {
            return [:]
        } else {
            fatalError("Failed to convert model object: \(self)")
        }
    }
}
