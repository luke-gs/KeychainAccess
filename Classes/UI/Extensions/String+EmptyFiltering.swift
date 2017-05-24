//
//  String+EmptyFiltering.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

extension String {
    
    /// - Returns: `self` iff `self` is not empty.
    public func ifNotEmpty() -> String? {
        if isEmpty == false {
            return self
        }
        return nil
    }
    
}
