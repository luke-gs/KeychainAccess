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

    // Add any other type conversions here...
}

/// Internal extension for pretty JSON formatting of dictionaries
fileprivate extension Dictionary {

    func asJSONString() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
}
