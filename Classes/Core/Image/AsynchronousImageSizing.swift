//
//  AsynchronousImageSizing.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

open class AsynchronousImageSizing: ImageLoadable {

    open let placeholderImage: ImageSizable?

    public init(placeholderImage: ImageSizable? = nil) {
        self.placeholderImage = placeholderImage
    }

    open func sizing() -> ImageSizing {
        if let sizing = placeholderImage?.sizing() {
            return sizing
        } else {
            return ImageSizing(image: nil, size: .zero)
        }
    }

    open func loadImage(completion: @escaping (ImageSizable) -> ()) {
        MPLRequiresConcreteImplementation()
    }

}
