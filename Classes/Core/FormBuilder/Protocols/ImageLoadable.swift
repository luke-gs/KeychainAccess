//
//  ImageLoadable.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// A protocol that allows the retrieving of image to be on demand.
/// `UIImage` implements this protocol.
public protocol ImageLoadable: ImageSizable {

    func requestImage(completion: @escaping (ImageSizable) -> ())

}

extension UIImage: ImageLoadable {

    /// UIImage immediately calls completion with self as ImageSizable
    ///
    /// - Parameter completion: The completion handler.
    public func requestImage(completion: @escaping (ImageSizable) -> ()) {
        completion(self)
    }

}
