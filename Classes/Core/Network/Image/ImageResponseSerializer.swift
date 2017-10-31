//
//  ImageResponseSerializer.swift
//  MPOLKit
//
//  Created by Herli Halim on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

extension DataRequest {

    private static var acceptableImageContentTypes: Set<String> = [
        "image/gif",
        "image/jpeg",
        "image/png",
        "image/tiff",
    ]

    public class var imageScale: CGFloat {
        return UIScreen.main.scale
    }

    /// Create a response serializer that returns a UIImage from the response data.
    ///
    /// - Parameter imageScale: The scale factor used for the image. Default is using the screen scale.
    /// - Returns: An image response serializer
    public class func imageResponseSerializer(imageScale: CGFloat = DataRequest.imageScale) -> DataResponseSerializer<UIImage> {
        return DataResponseSerializer { request, response, data, error in
            let result = serializeResponseData(response: response, data: data, error: error)

            guard case let .success(data) = result else {
                // It's either, if it's not successful, then error should be there.
                return .failure(result.error!)
            }

            do {
                try DataRequest.validateContentType(for: request, response: response)

                let image = try DataRequest.image(from: data, withImageScale: imageScale)

                return .success(image)
            } catch {
                return .failure(error)
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - imageScale: The scale factor used for the image. Default is using the screen scale.
    ///   - queue: The queue on which the handler is dispatched. `nil` by default. Turns into `DispatchQueue.main` by Alamofire.
    ///   - completionHandler: A closure to be executed once the request has finished.
    /// - Returns: The request.
    @discardableResult
    public func responseImage(imageScale: CGFloat = DataRequest.imageScale, queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<UIImage>) -> Void)
        -> Self {
            let imageSerializer = DataRequest.imageResponseSerializer(imageScale: imageScale)
            return response(queue: queue, responseSerializer: imageSerializer, completionHandler: completionHandler)
    }
    
    private class func image(from data: Data, withImageScale imageScale: CGFloat) throws -> UIImage {

        if let image = UIImage(data: data, scale: imageScale) {
            return image
        }

        throw ImageError.imageSerializationFailed
    }

    // MARK: - Validation

    /// Returns whether the content type of the response is supported type.
    ///
    /// - parameter request: The request to be validated.
    /// - parameter response: The server response to be validated.
    ///
    /// - throws: An `AFError` response validation failure when error occurred.
    public class func validateContentType(for request: URLRequest?, response: HTTPURLResponse?) throws {

        if let url = request?.url, url.isFileURL {
            return
        }

        guard let mimeType = response?.mimeType else {
            let contentTypes = Array(DataRequest.acceptableImageContentTypes)
            throw AFError.responseValidationFailed(reason: .missingContentType(acceptableContentTypes: contentTypes))
        }

        guard DataRequest.acceptableImageContentTypes.contains(mimeType) else {
            let contentTypes = Array(DataRequest.acceptableImageContentTypes)

            throw AFError.responseValidationFailed(
                reason: .unacceptableContentType(acceptableContentTypes: contentTypes, responseContentType: mimeType)
            )
        }
    }
}
