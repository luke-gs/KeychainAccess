//
//  MappedError.swift
//  MPOLKit
//
//  Created by Herli Halim on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct MappedError: LocalizedError {
    
    public var underlyingError: Error
    
    fileprivate let _errorDescription: String
    private let _failureReason: String?
    private let _recoverySuggestion: String?
    
    public init(errorDescription: String, failureReason: String? = nil, recoverySuggestion: String? = nil, underlyingError: Error) {
        _errorDescription = errorDescription
        _failureReason = failureReason
        _recoverySuggestion = recoverySuggestion
        self.underlyingError = underlyingError
    }
    
    public var errorDescription: String? {
        return _errorDescription
    }
    
    public var failureReason: String? {
        return _failureReason
    }
    
    public var recoverySuggestion: String? {
        return _recoverySuggestion
    }
}

extension MappedError: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        var userInfo: [String : Any] =  [NSUnderlyingErrorKey: underlyingError, NSLocalizedDescriptionKey: _errorDescription]
        
        if let failureReason = failureReason {
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        }
        
        if let recoverySuggestion = recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }
        return userInfo
    }
    
}

