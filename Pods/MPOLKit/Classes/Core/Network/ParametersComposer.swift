//
//  SearchQueryComposable.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol Parameterisable {
    var parameters: [String: Any] { get }
}

public struct ParametersComposer: Parameterisable {
    
    public let parameterComponents: [Parameterisable]
    
    public var parameters: [String : Any] {
        
        var parameters: [String: Any] = [:]
        
        for parameter in parameterComponents {
            
            parameter.parameters.forEach({
                parameters[$0.key] = $0.value
            })
        }
        return parameters
    }
    
}
