//
//  AsynchronousImageSizing.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

open class AsynchronousImageSizing: ImageLoadable {

    open var placeholderImage: ImageSizable?

    open var size: CGSize

    public init(placeholderImage: ImageSizable? = nil, size: CGSize = .zero) {
        self.placeholderImage = placeholderImage
        self.size = size
    }

    open func sizing() -> ImageSizing {
        if var sizing = placeholderImage?.sizing() {
            sizing.size = size
            return sizing
        } else {
            return ImageSizing(image: nil, size: size)
        }
    }

    open func loadImage(completion: @escaping (ImageSizable) -> ()) {
        MPLUnimplemented()
    }

}
