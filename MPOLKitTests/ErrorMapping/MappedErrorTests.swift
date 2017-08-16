//
//  MappedErrorTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import MPOLKit

class MappedErrorTests: XCTestCase {
    
    let errorDescription = "Fun"
    let failureReason = "Having too much fun!"
    let recoverySuggestion = "Stop having fun!"
    let underlyingError = NSError(domain: "FunErrorDomain", code: 1, userInfo: nil)
    
    func testThatItCreatesSuccessfully() {
        // Given
        // Described as constants above
        
        // When
        let error = MappedError(errorDescription: errorDescription, failureReason: failureReason, recoverySuggestion: recoverySuggestion, underlyingError: underlyingError)
        
        // Then
        XCTAssertEqual(error.errorDescription, errorDescription)
        XCTAssertEqual(error.localizedDescription, errorDescription)
        XCTAssertEqual(error.failureReason, failureReason)
        XCTAssertEqual(error.recoverySuggestion, recoverySuggestion)
        XCTAssertEqual(error.underlyingError as NSError, underlyingError)
    }

    func testThatNSErrorUserInfoCreatesCorrectly() {
        // Given
        // Described as constants above
        let userInfo: [String : Any] = [ NSLocalizedDescriptionKey: errorDescription, NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion, NSUnderlyingErrorKey: underlyingError, NSLocalizedFailureReasonErrorKey: failureReason]
        
        
        // When
        let error = MappedError(errorDescription: errorDescription, failureReason: failureReason, recoverySuggestion: recoverySuggestion, underlyingError: underlyingError)
        let errorUserInfo = error.errorUserInfo

        // Then
        let stringKeys = [NSLocalizedDescriptionKey, NSLocalizedRecoverySuggestionErrorKey, NSLocalizedFailureReasonErrorKey]
        let errorKey = NSUnderlyingErrorKey
        
        for key in stringKeys {
            XCTAssertEqual(userInfo[key] as! String, errorUserInfo[key] as! String)
        }
        XCTAssertEqual(userInfo[errorKey] as! NSError, errorUserInfo[errorKey] as! NSError)
    }
}
