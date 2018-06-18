//
//  LogUtils.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Utility class for logging
open class LogUtils {

    /// Convert a dictionary to a string for logging
    public static func string(from dictionary: [AnyHashable: Any]) -> String {
        return dictionary.asJSONString() ?? dictionary.debugDescription
    }

    /// Convert an array of dictionaries to a string for logging
    public static func string(from array: [[AnyHashable: Any]]) -> String {
        return array.asJSONString() ?? array.debugDescription
    }

    // Add any other type conversions here...
}

/// Internal extension for pretty JSON formatting of JSON objects
fileprivate protocol JSONObjectType {

    // Convert the object to a pretty formatted string
    func asJSONString() -> String?
}

fileprivate extension JSONObjectType {
    func asJSONString() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
}

extension Dictionary: JSONObjectType {}
extension Array: JSONObjectType {}
