//
//  LocationErrorDefinition.swift
//  MPOLKit
//
//  Created by Megan Efron on 27/4/18.
//

import Foundation

open class LocationErrorDefinition: ErrorMappable {
    
    public typealias SupportedTypeError = LocationErrorManagerError
    
    public init() { }
    
    open func mappedError(from error: Error) -> MappedError? {
        guard let error = error as? SupportedTypeError else { return nil }
        
        switch error {
        case .recoveryFailed:
            return MappedError(errorDescription: "Please ensure Location Services is enabled in Settings to continue.", underlyingError: error)
        }
    }
    
    open static var supportedType: Error.Type {
        return SupportedTypeError.self
    }
}
