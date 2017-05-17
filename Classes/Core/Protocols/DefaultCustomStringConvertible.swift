//
//  DefaultCustomStringConvertible.swift
//  MPOL
//
//  Created by Herli Halim on 8/5/17.
//
//

public protocol DefaultCustomStringConvertible: CustomStringConvertible { }

public extension DefaultCustomStringConvertible {
    
    public var description : String {
        var description: String = ""
        
        description = "\(type(of: self))"
        
        var lSelf = self
        withUnsafePointer(to: &lSelf) {
            description += " <\($0.debugDescription)>\n"
        }

        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += " - \(propertyName): \(child.value)\n"
            }
        }
        return description
    }
    
    
}


