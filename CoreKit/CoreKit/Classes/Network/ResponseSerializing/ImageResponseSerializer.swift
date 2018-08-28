//
//  ImageResponseSerializer.swift
//  MPOLKit
//
//  Created by Herli Halim on 1/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Alamofire

// Serializer that will turn `DataResponse<Data>` into `DataResponse<UIImage>`
public struct ImageResponseSerializer: ResponseSerializing {

    public typealias ResultType = UIImage

    // If not value is passed in, the value will be delegated to the underlying serializer.
    public let imageScale: CGFloat?

    public init(imageScale: CGFloat? = nil) {
        self.imageScale = imageScale
    }

    public func serializedResponse(from dataResponse: DataResponse<Data>) -> Result<ResultType> {
        let serializer: DataResponseSerializer<UIImage>

        if let imageScale = imageScale {
            serializer = DataRequest.imageResponseSerializer(imageScale: imageScale)
        } else {
            serializer = DataRequest.imageResponseSerializer()
        }
        
        return serializer.serializeResponse(nil, dataResponse.response, dataResponse.data, dataResponse.error)
    }

}
