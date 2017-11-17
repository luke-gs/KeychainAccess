//
//  ImageSizing.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A protocol representing items which can be converted into a `ImageSizing` type
/// `UIImage` implements this protocol.
public protocol ImageSizable {

    func sizing() -> ImageSizing

}

extension UIImage: ImageSizable {

    /// Returns an ImageSizing initialized with the image.
    ///
    /// - Returns: The ImageSizing.
    public func sizing() -> ImageSizing {
        return ImageSizing(image: self, size: self.size)
    }

}


public struct ImageSizing: ImageSizable {

    /// The image
    public var image: UIImage?

    /// The image size
    public var size: CGSize

    public var contentMode: UIViewContentMode?

    /// Initializes an ImageSizing struct.
    ///
    /// - Parameters:
    ///   - image: The image.
    ///   - size:  The size for this image.
    public init(image: UIImage?, size: CGSize, contentMode: UIViewContentMode? = nil) {
        self.image = image
        self.size = size
        self.contentMode = contentMode
    }


    /// Returns itself as its own ImageSizing representation.
    ///
    /// - Returns: The ImageSizing.
    public func sizing() -> ImageSizing {
        return self
    }

}

extension ImageSizing: Equatable {

    public static func ==(lhs: ImageSizing, rhs: ImageSizing) -> Bool {
        return lhs.image == rhs.image && lhs.size == rhs.size && lhs.contentMode == rhs.contentMode
    }

}
