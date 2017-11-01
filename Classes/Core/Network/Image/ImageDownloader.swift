//
//  ImageDownloader.swift
//  MPOLKit
//
//  Created by Herli Halim on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire
import PromiseKit

public class ImageDownloader {


}

public extension APIManager {

    /// Perform specified network request.
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return of specified type.
    public func performRequest(_ networkRequest: NetworkRequestType, imageScale: CGFloat? = nil) throws -> Promise<UIImage> {
        return try performRequest(networkRequest, using: ImageResponseSerializer(imageScale: imageScale))
    }

}
