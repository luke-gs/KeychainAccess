//
//  ResponseDataOperationChainable.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

public protocol HasDataResponse {
    
    associatedtype DataResponseValue
    
    /// The data response to be held and passed the data to next operation.
    var response: DataResponse<DataResponseValue>? { get }

}

public protocol DataResponseOperationChainable {
    
    associatedtype DataResponseResultType
    associatedtype DataResponseProviderType
    
    /// The completion handler that returns DataResponse
    var completionHandler: ((DataResponse<DataResponseResultType>) -> Void)? { get }
    
    init(provider: DataResponseProviderType, completionHandler: ((DataResponse<DataResponseResultType>) -> Void)?)
}
