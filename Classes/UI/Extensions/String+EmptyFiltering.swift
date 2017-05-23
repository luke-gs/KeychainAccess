//
//  String+EmptyFiltering.swift
//  Pods
//
//  Created by Rod Brown on 23/5/17.
//
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
