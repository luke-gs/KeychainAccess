//
//  ImageError.swift
//  MPOLKit
//
//  Created by Herli Halim on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

public enum ImageError: Error {
    case requestCancelled
    case imageSerializationFailed
}

// MARK: - Error Descriptions

extension ImageError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .requestCancelled:
            return "The request is cancelled."
        case .imageSerializationFailed:
            return "Failed to serialize data into image."
        }
    }

}
