//
//  Versionable.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

public protocol ModelVersionable {
    
    static var modelVersion: Int { get }
    var modelVersion: Int { get }
    
}

extension ModelVersionable {
    public static var modelVersion: Int {
        return 0
    }
    
    public var modelVersion: Int {
        return type(of: self).modelVersion
    }
    
}
