//
//  ErrorMapperTests.swift
//  MPOLKit
//
//  Created by Herli Halim on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Alamofire
@testable import MPOLKit

class ErrorMapperTests: XCTestCase {

    let networkDefinition = NetworkErrorDefinition()
    let dummyError = NSError(domain: "ErrorDomain", code: 1, userInfo: nil)
    
    func testThatItMapsErrorCorrectly() {
        // Given
        let statusCode = 400
        let rsp = dataResponse(statusCode: statusCode)
        let error = APIManagerError(underlyingError: dummyError, response: rsp)
        let errorMapper = ErrorMapper(definitions: [networkDefinition])
        
        // When
        let mapped = errorMapper.mappedError(from: error)

        // Then
        XCTAssertEqual(mapped.localizedDescription, NetworkErrorDefinition.defaultHTTPStatusCodesMap[statusCode]!.message)
    }
    
    func testThatItPassThroughNotSupportedStatusCode() {
        // Given
        let statusCode = 9001 // Over 9000
        let rsp = dataResponse(statusCode: statusCode)
        let error = APIManagerError(underlyingError: dummyError, response: rsp)
        let errorMapper = ErrorMapper(definitions: [networkDefinition])
        
        let originalErrorDescription = error.localizedDescription
        
        // When
        let mapped = errorMapper.mappedError(from: error)
        
        // Then
        // Verify that this is not supported
        XCTAssertNil(NetworkErrorDefinition.defaultHTTPStatusCodesMap[statusCode])
        // It should not be mapped. APIManagerError is not equatable, so we check whether
        // the description is still the same after the mapping process.
        XCTAssertEqual(originalErrorDescription, mapped.localizedDescription)
    }
    
    func testThatItPassThroughNotSupportedError() {
        // Given
        let error = dummyError
        let errorMapper = ErrorMapper(definitions: [networkDefinition])
        
        // When
        let mapped = errorMapper.mappedError(from: error)
        
        // Then
        // Verify that the definition doesn't support dummyError
        XCTAssertFalse(type(of: error) == type(of: networkDefinition).supportedType)
        XCTAssertEqual(mapped as NSError, error as NSError)
    }
    
    // MARK: - DefaultDataResponse
    
    func dataResponse(statusCode: Int) -> DefaultDataResponse {
        let url = URL(string: "https://www.apple.com")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        return DefaultDataResponse(request: nil, response: httpResponse, data: nil, error: dummyError)
    }
}

