//
//  ResponseDataOperationChainable.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

public protocol HasDataResponse {
    
    /// The data response to be held and passed the data to next operation.
    var response: DataResponse<Any>? { get }

}

public protocol DataResponseOperationChainable {
    
    associatedtype DataResponseResultType
    
    /// The completion handler that returns DataResponse
    var completionHandler: ((DataResponse<DataResponseResultType>) -> Void)? { get }
    
    init<T: Operation>(provider: T, completionHandler: ((DataResponse<DataResponseResultType>) -> Void)?) where T: HasDataResponse
    
}
