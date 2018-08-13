//
//  Accessories.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class ImageAccessoryItem: ItemAccessorisable {
    public var size: CGSize
    public let image: UIImage

    public init(image: UIImage) {
        self.size = image.size
        self.image = image
    }

    public func view() -> UIView {
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        return view
    }

    public func apply(theme: Theme, toView view: UIView) {

    }
}
