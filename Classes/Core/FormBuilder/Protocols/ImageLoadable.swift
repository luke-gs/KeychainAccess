//
//  ImageLoadable.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// A protocol that allows the retrieving of image to be on demand.

public protocol ImageLoadable: ImageSizable {

    func loadImage(completion: @escaping (ImageSizable) -> ())
    var size: CGSize { get }
}

/// Extends `UIImage` to implement ImageLoadable for convenience.
extension UIImage: ImageLoadable {

    /// UIImage immediately calls completion with self as ImageSizable
    ///
    /// - Parameter completion: The completion handler.
    public func loadImage(completion: @escaping (ImageSizable) -> ()) {
        completion(self)
    }
}


extension ImageSizing: ImageLoadable {

    public func requestImage(completion: @escaping (ImageSizable) -> ()) {
        completion(self)
    }

}
