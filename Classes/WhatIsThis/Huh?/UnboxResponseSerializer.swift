//
//  UnboxableResponseSerializer.swift
//  MPOLKit
//
//  Created by Herli Halim on 1/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import Alamofire

public struct UnboxableResponseSerializer<T: Unboxable>: ResponseSerializing {

    public typealias ResultType = T

    public let keyPath: String?

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    public func serializedResponse(from dataResponse: DataResponse<Data>) -> Result<ResultType> {
        return DataRequest.serializeResponseUnboxable(keyPath: keyPath, response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
    }

}

public struct UnboxableArrayResponseSerializer<T: Unboxable>: ResponseSerializing {

    public typealias ResultType = [T]

    public let keyPath: String?

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    public func serializedResponse(from dataResponse: DataResponse<Data>) -> Result<ResultType> {
        return DataRequest.serializeResponseUnboxableArray(keyPath: keyPath, response: dataResponse.response, data: dataResponse.data, error: dataResponse.error)
    }

}
