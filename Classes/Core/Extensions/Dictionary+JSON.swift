//
//  Dictionary+JSON.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

extension Dictionary {

    func asLogString() -> String {
        return asJSONString() ?? debugDescription
    }

    func asJSONString() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
}
