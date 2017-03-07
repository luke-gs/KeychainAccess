//
//  DefaultReusable.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

fileprivate var reuseIDMap: [String: String] = [:]

public protocol DefaultReusable: class {
    static var defaultReuseIdentifier: String { get }
}

public extension DefaultReusable {
    
    static var defaultReuseIdentifier: String {
        let key = self is NSObject.Type ? NSStringFromClass(self) : String(describing: self)
        let reuseID: String
        
        if let existingID = reuseIDMap[key] {
            reuseID = existingID
        } else {
            reuseID = UUID().uuidString
            reuseIDMap[key] = reuseID
        }
        
        return reuseID
    }
    
}
