//
//  ImageCodeableResponseSerializer.swift
//  MPOLKit
//
//  Created by Herli Halim on 1/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Alamofire
import Cache

// Serializer that will turn `DataResponse<UIImageWrapper>` into `DataResponse<UIImage>`
public struct ImageWrapperResponseSerializer: ResponseSerializing {
    public typealias ResultType = ImageWrapper

    // If not value is passed in, the value will be delegated to the underlying serializer.
    public let imageScale: CGFloat?

    public init(imageScale: CGFloat? = nil) {
        self.imageScale = imageScale
    }

    public func serializedResponse(from dataResponse: DataResponse<Data>) -> Alamofire.Result<ImageWrapper> {
        let serializer: DataResponseSerializer<ImageWrapper>

        if let imageScale = imageScale {
            serializer = DataRequest.imageWrapperResponseSerializer(imageScale: imageScale)
        } else {
            serializer = DataRequest.imageWrapperResponseSerializer()
        }

        return serializer.serializeResponse(nil, dataResponse.response, dataResponse.data, dataResponse.error)
    }

}
